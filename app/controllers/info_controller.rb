class InfoController < ApplicationController
  include GradesHelper
  include SubmissionsHelper

  helper_method :sort_column, :sort_direction, :predictions

  before_action :ensure_not_observer?, except: [:predictor, :syllabus]
  before_action :ensure_staff?, except: [:dashboard, :predictor, :syllabus]
  before_action :find_team,
    only: [:earned_badges, :multiplier_choices]
  before_action :find_students,
    only: [:earned_badges, :multiplier_choices, :final_grades_for_course ]
  before_action :use_current_course, only: [:earned_badges, :per_assign, :multiplier_choices, :gradebook]
  before_action :ensure_current_course_role?, only: :dashboard

  # Displays student and instructor dashboard
  def dashboard
    @events = Timeline.new(current_course).events_by_due_date
    render :dashboard, Info::DashboardCoursePlannerPresenter.build({
      student: current_student,
      assignments: current_course.assignments.chronological,
      course: current_course,
      view_context: view_context
    })
  end

  def syllabus
  end

  # Display the grade predictor
  def predictor
  end

  def earned_badges
    @teams = @course.teams
    @badges = @course.badges.ordered
  end

  # Displaying ungraded submissions, and existing grades by status
  def grading_status
    @has_submissions_or_grades = ungraded_submissions_count_for(current_course).positive? ||
      in_progress_grades_count_for(current_course).positive? ||
      ready_for_release_grades_count_for(current_course).positive? ||
      resubmission_count_for(current_course).positive?
  end

  # Displaying per assignment summary outcome statistics
  def per_assign
    @assignment_types = @course.assignment_types.ordered.includes(:assignments)
  end

  def export_earned_badges
    course = Course.find_by(id: params[:id])
    respond_to do |format|
      format.csv do
        send_data EarnedBadgeExporter.new.earned_badges_for_course(course.earned_badges),
        filename: "#{course.name} Awarded #{ term_for :badges } - #{ Date.today }.csv"
      end
    end
  end

  def final_grades
    course = current_user.courses.find_by(id: params[:id])
    respond_to do |format|
      format.csv do
        send_data CourseGradeExporter.new.final_grades_for_course(course),
        filename: "#{ course.name } Final Grades - #{ Date.today }.csv"
      end
    end
  end

  def gradebook
  end

  def learning_objectives_outcomes_file
    course = current_user.courses.find_by(id: params[:id])
    LearningObjectivesOutcomesExporterJob
      .new(
        user_id: current_user.id,
        course_id: course.id,
        filename: "#{ course.name } Learning Objectives Outcomes - #{ Date.today }.csv"
      ).enqueue
      
    flash[:notice]="Your request to export the learning objectives outcomes for \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  def gradebook_file
    course = current_user.courses.find_by(id: params[:id])
    GradebookExporterJob
      .new(
        user_id: current_user.id,
        course_id: course.id,
        filename: "#{ course.name } Gradebook - #{ Date.today }.csv"
      ).enqueue

    flash[:notice]="Your request to export the gradebook for \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  def multiplied_gradebook
    course = current_user.courses.find_by(id: params[:id])
    MultipliedGradebookExporterJob
      .new(user_id: current_user.id, course_id: course.id, filename: "#{ course.name } Multiplied Gradebook - #{ Date.today }.csv").enqueue

    flash[:notice]="Your request to export the multiplied gradebook for \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  # downloadable grades for course with  export
  def research_gradebook
    course = current_user.courses.find_by(id: params[:id])
    @grade_export_job = GradeExportJob.new(user_id: current_user.id, course_id: course.id,
    filename: "#{ course.name } Research Gradebook - #{ Date.today }.csv")
    @grade_export_job.enqueue

    flash[:notice]="Your request to export grade data from course \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  # Chart displaying all of the student weighting choices thus far
  def multiplier_choices
    @assignment_types = current_course.assignment_types.ordered
    @teams = current_course.teams
  end

  def start_end_dates(Course)
    date_range = {}

    previous_days_permitted = course.export_date_range_days

    begin
      date_range[:end_date] =  params.key?(:end_date) ? Date.strptime(params[:end_date], "%Y-%m-%d") : Date.today
      date_range[:start_date] = params.key?(:start_date) ? Date.strptime(params[:start_date], "%Y-%m-%d") : date_range[:end_date] - previous_days_permitted
    rescue ArgumentError
      puts "Invalid date"
      date_range[:start_date] = Date.today - previous_days_permitted
      date_range[:end_date] = Date.today
    end

    puts "Start: #{date_range[:start_date]}"
    puts "End: #{date_range[:end_date]}"

    if date_range[:start_date] > date_range[:end_date]
      date_range[:start_date] = date_range[:end_date] - previous_days_permitted
    end

    if date_range[:end_date] - date_range[:start_date] > previous_days_permitted
      date_range[:start_date] = date_range[:end_date] - previous_days_permitted
    end


    puts "Start: #{date_range[:start_date]}"
    puts "End: #{date_range[:end_date]}"

    return date_range
  end

  def submissions
    field = params.key?(:field) && SubmissionExporter.field_for_export?(params[:field]) ? params[:field] : "created_at"
    course = current_user.courses.find_by(id: params[:id])
    date_range = start_end_dates(course)

    @submission_export_job = SubmissionExportJob.new(user_id: current_user.id, course_id: course.id, filename: "#{ course.name } Submissions Export - #{ Date.today }.csv", start_date: date_range[:start_date], end_date: date_range[:end_date], field: field)
    @submission_export_job.enqueue

    flash[:notice]="Your request to export submissions from course \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  private

  def find_team
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
  end

  def find_students
    if @team
      @students = current_course.students_being_graded_by_team(@team).order_by_name
    else
      @students = current_course.students_being_graded.order_by_name
    end
  end

  def ensure_current_course_role?
    if current_user.role(current_course).nil?
      next_course = current_user.course_memberships.first.try(:course)
      return redirect_to change_course_path(next_course) unless next_course.nil?
      redirect_to errors_path status_code: 401, error_type: "without_course_membership"
    end
  end
end

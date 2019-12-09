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
    LearningObjectiveOutcomesExporterJob
      .perform_async(
        current_user.id,
        course.id,
        "#{ course.name } Learning Objectives Outcomes - #{ Date.today }.csv"
      )

    flash[:notice]="Your request to export the learning objectives outcomes for \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  def gradebook_file
    course = current_user.courses.find_by(id: params[:id])
    GradebookExporterJob
      .perform_async(
        current_user.id,
        course.id,
        "#{ course.name } Gradebook - #{ Date.today }.csv"
      )

    flash[:notice]="Your request to export the gradebook for \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  def multiplied_gradebook
    course = current_user.courses.find_by(id: params[:id])
    MultipliedGradebookExporterJob
      .perform_async(current_user.id, course.id, "#{ course.name } Multiplied Gradebook - #{ Date.today }.csv")

    flash[:notice]="Your request to export the multiplied gradebook for \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  # downloadable grades for course with  export
  def research_gradebook
    course = current_user.courses.find_by(id: params[:id])
    @grade_export_job = GradeExportJob.perform_async(current_user.id, course.id)

    flash[:notice]="Your request to export grade data from course \"#{ course.name }\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  # Chart displaying all of the student weighting choices thus far
  def multiplier_choices
    @assignment_types = current_course.assignment_types.ordered
    @teams = current_course.teams
  end

  def submissions
    course = current_user.courses.find_by(id: params[:id])
    @submission_export_job = SubmissionListExporterJob.perform_async(current_user.id, course.id, "#{ course.name } Submissions Export - #{ Date.today }.csv")

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

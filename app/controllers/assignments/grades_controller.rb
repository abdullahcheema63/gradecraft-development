require_relative "../../services/creates_many_grades"

class Assignments::GradesController < ApplicationController
  before_action :ensure_staff?, except: [:self_log, :delete_self_logged]
  before_action :find_assignment, only: [:mass_edit, :mass_update, :self_log, :delete_self_logged, :delete_all]
  before_action :use_current_course, only: [:mass_edit, :mass_update, :delete_self_logged]

  # GET /assignments/:assignment_id/grades/export
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment. This has more detail about the student.
  def export
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv do
        send_data(GradeExporter.new
          .export_grades_with_detail(assignment, assignment.course.students),
          filename: "#{ assignment.name } Grades - #{ Date.today }.csv")
      end
    end
  end

  # GET /assignments/:assignment_id/grades/export_earned_levels
  def export_earned_levels
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv { send_data CriterionGradesExporter.new.export(assignment.course, assignment.rubric), filename: "#{ assignment.name } Rubric Grades - #{ Date.today }.csv" }
    end
  end

  # GET /assignments/:assignment_id/grades
  # View criterion grades for all students in the course for the assignment
  def index
    assignment = current_course.assignments.find(params[:assignment_id])
    # rubocop:disable AndOr
    redirect_to assignment_path(assignment) and return unless assignment.grade_with_rubric?

    # TODO: This should not use an AssignmentPresenter
    render :index, Assignments::Presenter.build({
      assignment: assignment,
      course: current_course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  # GET /assignments/:assignment_id/grades/mass_edit
  # Quickly grading a single assignment for all students
  def mass_edit
    redirect_to mass_edit_assignment_groups_grades_path and return if @assignment.has_groups?
  end

  # PUT /assignments/:assignment_id/grades/mass_update
  # Updates all the grades for the students or groups in a course for an assignment
  def mass_update
    filter_params_with_no_grades!
    params[:assignment][:grades_attributes] = params[:assignment][:grades_attributes].each do |key, value|
      value.merge!(instructor_modified: true, complete: true, student_visible: true)
    end
    result = Services::CreatesManyGrades.call @assignment.id, current_user.id, assignment_params[:grades_attributes]

    if result.success?
      if !params[:team_id].blank?
        redirect_to assignment_path(@assignment, team_id: params[:team_id])
      else
        respond_with @assignment
      end
    else
      redirect_to mass_edit_assignment_grades_path(@assignment, team_id: params[:team_id]),
        notice: "Oops! There was an error while saving the grades!"
    end
  end

  # DELETE /assignments/:assignment_id/grades/delete_all
  # Delete grades for a given assignment id
  def delete_all
    if params[:team_id].present?
      team = current_course.teams.find_by(id: params[:team_id])
      students = current_course.students_being_graded_by_team(team).order_by_name
    else
      students = current_course.students_being_graded.order_by_name
    end

    Gradebook.new(@assignment, students).existing_grades.each do |grade|
      grade.destroy
      ScoreRecalculatorJob.perform_async(grade.student_id, current_course.id)
    end

    redirect_to assignment_path(@assignment), flash: {
      success: "Successfully deleted grades for #{ @assignment.name }"
    }
  end

  # PUT /assignments/:assignment_id/grades/self_log
  # Allows students to log grades for student logged assignments
  # either sets raw points to params[:grade][:raw_points]
  # or defaults to point total for assignment
  def self_log
    if @assignment.open? && @assignment.student_logged?
      @grade = Grade.find_or_create(@assignment.id, current_student.id)

      if params[:grade].present? && params[:grade][:raw_points].present?
        @grade.raw_points = params[:grade][:raw_points]
      elsif params[:grade].present? && params[:grade][:pass_fail_status].present?
        @grade.pass_fail_status = params[:grade][:pass_fail_status]
      elsif !@assignment.assignment_score_levels.exists?
        @grade.raw_points = @assignment.full_points
      else
        redirect_back fallback_location: assignments_path,
          notice: "We're sorry, there was an error saving your grade."

        return
      end

      @grade.assign_attributes(
        instructor_modified: true,
        student_visible: true,
        complete: true,
        graded_at: DateTime.now,
        graded_by_id: current_student.id
      )

      if @grade.save
        grade_updater_job = GradeUpdaterJob.perform_async(@grade.id)

        redirect_to assignments_path,
          notice: "Nice job! Thanks for logging your grade!"
      else
        redirect_to assignments_path,
          notice: "We're sorry, there was an error saving your grade."
      end

    else
      redirect_to dashboard_path,
        notice: "This assignment is not open for self grading."
    end
  end

  def delete_self_logged
    if !current_course.delete_student_logged_grade
      redirect_to assignments_path,
        notice: "Ask an instructor in this course to allow you to delete student logged grades."
    end

    if !@assignment.open? || !@assignment.student_logged?
      redirect_to assignments_path,
        notice: "You cannot edit the grade for this assignment because it is not open or not student logged." and return
    end

    @grade = Grade.find_by(assignment_id: @assignment.id, student_id: current_student.id)

    if @grade.nil?
      redirect_to assignments_path,
        notice: "No self logged grade found."
    end

    @grade.destroy

    ScoreRecalculatorJob.perform_async(current_student.id, current_course.id)


    message = "#{current_student.first_name} #{current_student.last_name}'s' self logged grade for this assignment has been deleted."

    message = "Your grade for this assignment has been deleted." if current_user.is_student?(current_course)

    redirect_to assignments_path,
          notice: message
  end

  private

  def assignment_params
    params.require(:assignment).permit grades_attributes: [:graded_by_id, :graded_at,
      :instructor_modified, :student_id, :raw_points, :pass_fail_status, :id, :complete, :student_visible]
  end

  # Delete params that have no raw_points or pass_fail_status
  # We remove pass_fail_status values of "nil" because we have a "No Change" radio button
  # on the UI, and by default a radio button must have some sort of string value
  def filter_params_with_no_grades!
    params[:assignment][:grades_attributes] = params[:assignment][:grades_attributes].delete_if do |key, value|
      value[:raw_points].blank? && (value[:pass_fail_status].blank? || value[:pass_fail_status] == "nil")
    end
  end

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.perform_async(id) }
  end

  def find_assignment
    @assignment = current_course.assignments.find(params[:assignment_id])
  end
end

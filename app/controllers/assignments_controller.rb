# rubocop:disable AndOr
require "canvas"

class AssignmentsController < ApplicationController
  include AssignmentsHelper

  before_action :ensure_staff?, except: [:show, :index]
  before_action :use_current_course, only: [:index, :settings, :show, :new, :edit, :grades_review]

  def index
    @assignment_types = @course.assignment_types.ordered.includes(:assignments)
    if current_user_is_student? || current_user_is_observer?
      render :index, Assignments::StudentPresenter.build({
        student: current_student,
        assignment_types: @course.assignment_types.ordered.includes(assignments: :unlock_keys),
        course: @course,
        view_context: view_context
      })
    end
  end

  # Gives the instructor the chance to quickly check all assignment settings
  # for the whole course
  def settings
    @assignment_types = @course.assignment_types.ordered.includes(:assignments)
  end

  def show
    @assignment = @course.assignments.find_by(id: params[:id])
    redirect_to assignments_path,
      alert: "The #{(term_for :assignment)} could not be found." and return unless @assignment.present?

    mark_assignment_reviewed! @assignment, current_user
    render :show, Assignments::Presenter.build({
      assignment: @assignment,
      course: @course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  def new
    render :new, Assignments::Presenter.build({
      assignment: @course.assignments.new,
      course: @course,
      view_context: view_context
      })
  end

  def edit
    @assignment = current_course.assignments.find params[:id]
    @rubric = @assignment.find_or_create_rubric
  end

  # Duplicate an assignment - important for super repetitive items like
  # attendance and reading reactions
  def copy
    begin
      assignment = current_course.assignments.find(params[:id])
      duplicated = assignment.copy_with_prepended_name
      copy_unlock_conditions(assignment, duplicated)
      redirect_to edit_assignment_path(duplicated), notice: "#{(term_for :assignment).titleize} #{duplicated.name} successfully created"
    rescue CopyValidationError => e
      render json: { message: e.message, details: e.details }, status: :internal_server_error
    end
  end

  def destroy
    assignment = current_course.assignments.find(params[:id])
    assignment.destroy
    redirect_to params[:redirect_path] || assignments_url, notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully deleted"
  end

  def export_structure
    course = current_user.courses.find_by(id: params[:id])
    respond_to do |format|
      format.csv { send_data AssignmentExporter.new(current_user, course).export, filename: "#{ course.name } #{ (term_for :assignment).titleize } Structure - #{ Date.today }.csv" }
    end
  end

  def grades_review
    @assignment = @course.assignments.find(params[:id])
    if @assignment.grade_with_rubric?
      @criteria = @assignment.rubric.criteria.includes(levels: :level_badges)
      @criterion_grades = @assignment.criterion_grades
    end
    render :grades_review, Assignments::Presenter.build({
      assignment: @assignment,
      course: @course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end
end

def copy_unlock_conditions(assignment, duplicated)
  UnlockCondition.where(unlockable_id: assignment.id, course: assignment.course, unlockable_type: "Assignment").each do |condition|
    copied_unlock_condition = condition.copy
    copied_unlock_condition.unlockable_id = duplicated.id
    copied_unlock_condition.save
  end
end

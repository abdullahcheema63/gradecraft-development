class API::LearningObjectives::LevelsController < ApplicationController
  before_action :ensure_course_uses_objectives?
  before_action :ensure_staff?
  before_action :find_objective

  # POST /api/learning_objectives/:objective_id/levels
  def create
    @level = @objective.levels.new learning_objective_level_params

    if @level.save
      render "api/learning_objectives/levels/show", status: 201
    else
      render json: {
        message: "Failed to create learning objective level",
        errors: @level.errors.messages,
        success: false
      }, status: 400
    end
  end

  # PUT /api/learning_objectives/:objective_id/levels/:id
  def update
    @level = @objective.levels.find params[:id]

    if @level.update_attributes learning_objective_level_params
      render "api/learning_objectives/levels/show", status: 200
    else
      render json: {
        message: "Failed to update learning objective level",
        errors: @level.errors.messages,
        success: false
      }, status: 400
    end
  end

  # DELETE /api/learning_objectives/:objective_id/levels/:id
  def destroy
    observed_outcomes_for_level = LearningObjectiveObservedOutcome.where(objective_level_id: params[:id])
    
    if observed_outcomes_for_level.exists?
      cumulative_outcome_ids = observed_outcomes_for_level.pluck("learning_objective_cumulative_outcomes_id")
      user_ids = LearningObjectiveCumulativeOutcome.where(id: cumulative_outcome_ids).pluck("user_id")
      active_members = CourseMembership.where(user_id: user_ids, course_id: current_course.id, active: true).any?
      
      if active_members
        render json: { message: "Failed to delete level as it has already been used to assess students. Reassess these students using a different level to delete this level. ", success: false },
        status: 500
        return
      end
    end

    levels_count = @objective.levels.length - 1
    
    if levels_count < 2
      render json: { message: "Cannot delete levels as there should be at least two levels for a learning objective.", success: false },
      status: 500
      return
    end

    @level = @objective.levels.find params[:id]
    @level.destroy

    if @level.destroyed?
      render json: { message: "Deleted #{@level.name}", success: true },
        status: 200
    else
      render json: { message: "Failed to delete #{@level.name}", success: false },
        status: 500
    end
  end

  # PUT /api/learning_objectives/objectives/:objective_id/levels/update_order
  def update_order
    begin
      LearningObjectiveLevel.transaction do
        params[:level_ids].each_with_index { |id, index| @objective.levels.find(id).update order: index }
      end
      render json: { message: "Updated ordering", success: true }, status: 200
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      render json: { message: "Failed to update ordering", success: false }, status: 500
    end
  end

  private

  def learning_objective_level_params
    params.require(:learning_objective_level).permit :id, :name, :description, :flagged_value
  end

  def find_objective
    @objective = current_course.learning_objectives.find params[:objective_id]
  end
end

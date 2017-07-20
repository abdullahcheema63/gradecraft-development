class API::BadgesController < ApplicationController
  include SortsPosition

  before_action :ensure_staff?, except: [:index]

  # GET api/badges
  def index
    @badges = current_course.badges.ordered.select(
      :can_earn_multiple_times,
      :course_id,
      :description,
      :full_points,
      :icon,
      :id,
      :name,
      :position,
      :visible,
      :visible_when_locked)

    if current_user_is_student?
      @student = current_student
      @allow_updates = !impersonating? && current_course.active?

      if !impersonating?
        @badges.includes(:predicted_earned_badges)
        @predicted_earned_badges =
          PredictedEarnedBadge.for_course(current_course).for_student(current_student)
      end
    end
  end

  def show
    @badge = Badge.find(params[:id])
  end

  # PUT api/badges/:id
  def update
    @badge = Badge.find(params[:id])
    if @badge.update_attributes badge_params
      render "api/badges/show", success: true, status: 200
    else
      render json: {
        message: "failed to save badge",
        errors: @badge.errors.messages,
        success: false
        }, status: 400
    end
  end

  def create
    #TODO
  end

  def sort
    sort_position_for :badge
  end

  private

  def badge_params
    params.require(:badge).permit(:name, :description, :icon, :visible, :full_points,
      :can_earn_multiple_times,
      :position, :visible_when_locked, :course_id, :course, :show_name_when_locked,
      :show_points_when_locked, :show_description_when_locked, :student_awardable
    )
  end
end

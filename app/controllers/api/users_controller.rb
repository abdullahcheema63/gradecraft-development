# rubocop:disable AndOr
class API::UsersController < ApplicationController
  before_action :ensure_admin?, only: [:index, :instructors]

  # GET api/users
  def index
    @users = User.where(admin: false)
  end

  # GET api/users/instructors
  def instructors
    @instructors = CourseMembership.instructors
  end

  # GET api/users/:id
  def show
    user_id = params[:id]
    @user = User.find(user_id)
  end

  # PUT api/users/seen_onboarding
  def seen_onboarding
    puts "inside users#seen_onboarding "
    current_user.update_attribute(:has_seen_onboarding, true)
  end
end

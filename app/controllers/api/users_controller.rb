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
end

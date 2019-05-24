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
end

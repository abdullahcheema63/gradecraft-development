require "mongoid"

# rubocop:disable AndOr
class OverviewController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: [:courses, :users]

  layout "blank"

  include ApplicationHelper

  def index
    # Only checks the current role of the user in the current course they are in
    # Should really only be used to determine if user is Admin or not
    @user_role = current_role
    @title = "Overview"
  end

  def courses
    @title = "courses"
  end

  def users
    @title = "users"
  end

end

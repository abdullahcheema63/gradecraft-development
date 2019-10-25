require "mongoid"

# rubocop:disable AndOr
class OverviewController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: [:courses, :users]

  layout "blank"

  include ApplicationHelper

  def index
    @title = "Overview"
  end

  def courses
    @title = "courses"
  end

  def users
    @title = "users"
  end

end

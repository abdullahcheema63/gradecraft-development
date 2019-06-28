
# rubocop:disable AndOr
class LicensesController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_staff?

  layout "blank"

  include ApplicationHelper

  # root
  # GET /
  def index
    @title = "Licenses"
    @user = current_user
    @stripePk = Rails.configuration.stripe[:publishable_key]
  end
end

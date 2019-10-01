
# rubocop:disable AndOr
class SubscriptionsController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_staff?

  layout "blank"

  include ApplicationHelper

  # root
  # GET /
  def index
    @title = "Subscriptions"
    @user = current_user
    @stripePk = Rails.configuration.stripe[:publishable_key]
    @stripeSk = Rails.configuration.stripe[:secret_key]
  end
end

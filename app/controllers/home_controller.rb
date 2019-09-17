# rubocop:disable AndOr
class HomeController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: :health_check
  before_action :redirect_if_logged_in!, only: [:index, :login]

  layout "blank", only: :style_guide

  # root
  # GET /
  def index
  end

  def login
  end

  def reset_password
  end

  def style_guide
  end

  def health_check
    begin
      @redis_status = Redis.redis.call("ping") == "PONG" ? "Connected" : "Error"
    rescue StandardError => e
      @error = e.message
      raise
    end
  end

  private

  def redirect_if_logged_in!
    redirect_to dashboard_path and return if logged_in?
  end
end

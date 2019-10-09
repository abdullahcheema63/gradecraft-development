require "mongoid"

# rubocop:disable AndOr
class HomeController < ApplicationController
  skip_before_action :require_login, except: [:overview]
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: :health_check
  before_action :redirect_if_logged_in!, only: [:index, :login]

  layout "blank", only: [:style_guide, :overview]

  include ApplicationHelper

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
      @mongo_status = Mongoid.default_client.command(ping: 1).documents.first == {"ok"=>1.0} ? "Connected" : "Error"
      @redis_status = Resque.redis.redis.call("ping") == "PONG" ? "Connected" : "Error"
    rescue StandardError => e
      @error = e.message
      raise
    end
  end

  def overview
    # Only checks the current role of the user in the current course they are in
    # Should really only be used to determine if user is Admin or not
    @user_role = current_role
    @title = "Overview"
  end

  private

  def redirect_if_logged_in!
    redirect_to overview_index_path and return if logged_in?
  end
end

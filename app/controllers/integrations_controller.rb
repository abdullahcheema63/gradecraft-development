class IntegrationsController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :integration_id

  before_action :ensure_staff?
  before_action except: :index do |controller|
    controller.redirect_path(integration_courses_path(params[:integration_id]))
  end
  before_action :link_canvas_credentials, except: :index,
    if: Proc.new { |c| c.params[:integration_id] == "canvas" }
  before_action :require_authorization, except: :index
  before_action :use_current_course, only: :index

  def index
    authorize! :read, @course
  end

  def create
    redirect_to integration_courses_path(params[:integration_id])
  end
end

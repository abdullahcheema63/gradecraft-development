# rubocop:disable AndOr
class API::CoursesController < ApplicationController
  before_action :ensure_staff?, only: [:show, :copy, :create, :unpublish, :publish, :archive, :destroy]
  before_action :use_current_course, only: [:analytics, :one_week_analytics]
  before_action :ensure_admin?, only: [:unarchive]

  # skip_before_action :verify_authenticity_token, only: :create

  # GET api/search
  # Used specifically for typeahead on course search input
  def search
    course_attrs = current_user.courses.map do |c|
      {
        id: c.id,
        formatted_name: c.formatted_long_name,
        search_string: c.searchable_name
      }
    end
    render json: MultiJson.dump(course_attrs)
  end

  # GET api/courses
  def index
    @courses = current_user_is_admin? ? Course.all.ordered_by_name : current_user.courses

    if current_user_is_admin?
      render json: MultiJson.dump(course_ids: @courses.pluck(:id)), status: :ok \
        and return if params[:fetch_ids] == "1"

      @courses = @courses.where(id: params[:course_ids]) if params[:course_ids].present?
    end
  end

  # GET /api/courses/:id
  def show
    @course = Course.includes(:grade_scheme_elements).find params[:id]
  end

  # POST /api/courses/copy
  #instructor's use in overview
  def copy
    course_params = format_course_params(params)
    course_id = params["id"]

    @course = Course.find(course_id)
    authorize! :read, @course

    begin
      duplicated = @course.copy(course_id)
      duplicated.update(course_params)
      duplicated.published = false
      if duplicated.save
        if !current_user_is_admin? && current_user.role(duplicated).nil?
          duplicated.course_memberships.create(user: current_user, role: current_role)
        end

        session[:course_id] = duplicated.id
      end
    end
  end

  # POST /api/courses
  def create
    course_params = format_course_params(params)
    @course = Course.new(course_params)

    if @course.save
      if !current_user_is_admin?
        @course.course_memberships.create(user_id: current_user.id,
                                          role: current_user.role(current_course))
      end
      session[:course_id] = @course.id
    else
      puts("Course was not saved")
    end
  end

  # DELETE /api/courses/:id
  def destroy
    course_id = params[:id]
    @course = Course.find(course_id)
    authorize! :destroy, @course
    @course.destroy
  end

  # PUT /api/courses/unpublish
  def unpublish
    course_id = params[:_json]
    #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify
    @course = Course.find(course_id)
    if @course
      authorize! :update, @course
      @course.update(published: false)
    end
  end

  # PUT /api/courses/publish
  def publish
    course_id = params[:_json]
    #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify
    @course = Course.find(course_id)
    if @course && (@course.subscription_id || Rails.env.production?)
      authorize! :update, @course
      authorize! :publish, @course
      @course.update(published: true)
    end
    if @course && !@course.active?
      authorize! :update, @course
      # authorize! :publish, @course (EB: for some reason this line does not allow you to publish "show" the course )
      @course.update(published: true)
    end
  end

  def archive
    course_id = params[:_json]
    #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify
    @course = Course.find(course_id)
    if @course
      authorize! :update, @course
      @course.update(status: false)
      @course.unsubscribe
    end
  end

  def unarchive
    course_id = params[:_json]
    #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify
    @course = Course.find(course_id)
    if @course
      authorize! :update, @course
      @course.update(published: false)
      @course.update(status: true)
    end
  end

  # GET api/courses/analytics
  def analytics
    if current_user_is_student?
      @student = current_user
      @user_score = @student.course_memberships.where(course_id: @course, auditing: false).pluck("score").first
    end
  end

  # GET api/courses/one_week_analytics
  def one_week_analytics
    if current_user_is_student?
      @student = current_user
    else
      @student = User.find(params[:student_id]) if params[:student_id]
    end
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end

  private

  def format_course_params(params)
    term = params["term"]
    formatted_params = {
      "course_number" => params["number"],
      "name" => params["name"],
      "semester" => term["name"],
      "year" => term["year"],
      "start_date" => term["start"],
      "end_date" => term["end"],
    }
  end
end

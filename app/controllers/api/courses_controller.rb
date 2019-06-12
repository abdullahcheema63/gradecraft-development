# rubocop:disable AndOr
class API::CoursesController < ApplicationController
  before_action :ensure_staff?, only: :show
  before_action :use_current_course, only: [:analytics, :one_week_analytics]

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

  # POST /api/courses
  def create
    puts("inside api/courses#create")
    course_params = format_course_params(params)

    @course = Course.new(course_params)
    if @course.save
      puts("saved created course")
      if !current_user_is_admin?
        puts("current_user.id", current_user.id)
        @course.course_memberships.create(user_id: current_user.id,
                                          role: current_user.role(current_course))
      end
      session[:course_id] = @course.id
    else
      puts("Course was not saved")
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
      "has_paid" => params["licensed"]
    }
  end
end

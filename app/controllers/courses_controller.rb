# rubocop:disable AndOr
class CoursesController < ApplicationController
  include CoursesHelper

  layout "public", only: :new_external

  skip_before_action :require_login, only: [:badges, :new_external, :create_external]
  skip_before_action :require_course_membership, only: [:badges, :new_external, :create_external]
  before_action :ensure_staff?, except: [:index, :badges, :change, :new_external, :create_external]
  before_action :ensure_not_impersonating?, only: [:index]
  before_action :ensure_admin?, only: [:copy, :activate_all_students, :recalculate_student_scores, :overview]
  before_action :ensure_can_create_courses?, only: [:new, :create]
  before_action :find_course, only: [:edit,
                                     :copy,
                                     :update,
                                     :destroy,
                                     :badges,
                                     :publish,
                                     :unpublish,
                                     :recalculate_student_scores]
  skip_before_action :verify_authenticity_token, only: [:change]
  before_action :ensure_not_impersonating?, only: [:change]
  before_action :save_referer, only: [:activate_all_students]

  def index
    @courses = current_user.courses.includes(:earned_badges)
    @can_create_courses = current_user_is_admin?
  end

  def overview
    @courses = Course.includes(:earned_badges).all
  end

  def new
    @course = Course.new
  end

  # Page for users without current access to the app to create new courses
  # The is step #3 in the process, where step #1 is that they create their own
  # account and #2 is that they activate it
  def new_external
    @course = Course.new
    @user = User.find(params[:user_id])
  end

  # It should automatically assign this user as a professor, as they will then
  # be creating a course that they can manage
  def create_external
    @course = Course.new(course_params)
    @user = User.find(params[:user_id])
    if @course.save
      @course.course_memberships.create(user_id: @user.id,
                                        role: "professor")
      session[:course_id] = @course.id
      auto_login @user
      @user.update_login_at
      @user.update_course_login_at(@course.id)
      redirect_to dashboard_path, flash: {
        notice: "Course #{@course.name} successfully created"
      }
    else
      redirect_to new_external_courses_path, flash: {
        alert: @course.errors.full_messages.to_sentence
      }
    end
  end

  def edit
    if @course.id != current_course.id
      change_current_course @course.id
      redirect_to action: :edit, id: @course.id and return
    end
    authorize! :update, @course
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      if !current_user_is_admin?
        @course.course_memberships.create(user_id: current_user.id,
                                          role: current_user.role(current_course))
      end
      session[:course_id] = @course.id
      bust_course_list_cache current_user
      current_user.update_login_at
      current_user.update_course_login_at(@course.id)
      redirect_to edit_course_path(@course), flash: {
        notice: "Course #{@course.name} successfully created"
      }
    else
      render action: "new", flash: {
        alert: @course.errors.full_messages.to_sentence
      }
    end
  end

  def copy_learning_objectives(course)
    course.learning_objectives.each do |learning_objective|
      if learning_objective.category.present?
          learning_objective.category = find_learning_objective_category(course, learning_objective.category.name)
      end
    end
  end

  def find_learning_objective_category(course, name)
    course.learning_objective_categories.each do |category|
        if category.name == name
            return category
        end
    end
  end

  def copy
    authorize! :read, @course


    begin
      duplicated = @course.copy(params[:copy_type])

      if @course.has_learning_objectives?
        copy_learning_objectives(duplicated)
      end

      if duplicated.save
        if !current_user_is_admin? && current_user.role(duplicated).nil?
          duplicated.course_memberships.create(user: current_user, role: current_role)
        end
        duplicated.recalculate_student_scores unless duplicated.student_count.zero?
        session[:course_id] = duplicated.id
        redirect_to edit_course_path(duplicated.id), flash: {
          notice: "#{@course.name} successfully copied"
        }
      else
        redirect_to courses_path, flash: {
          alert: "#{@course.name} was not successfully copied"
        }
      end
    rescue CopyValidationError => e
      render json: { message: e.message, details: e.details }, status: :internal_server_error
    end
  end

  def update
    authorize! :update, @course
    if @course.update_attributes(course_params)
      @course.recalculate_student_scores if add_team_score_to_student_changed?
      bust_course_list_cache current_user
      redirect_to edit_course_path(@course),
      notice: "Course #{@course.name} successfully updated"
    else
      @institutions = Institution.where(has_site_license: true)
      render action: "edit"
    end
  end

  def publish
    authorize! :update, @course
    authorize! :publish, @course
    @course.update(published: true)
    redirect_to dashboard_path, flash: {
      success: "This course has been published"
    }
  end

  def unpublish
    authorize! :update, @course
    @course.update(published: false)
    redirect_to dashboard_path, flash: {
      success: "This course has been unpublished"
    }
  end

  def activate_all_students
    course = current_user.courses.where(id: params[:id]).first
    students = User.accounts_not_activated(course)
    total = students.count
    students.each do |student|
      student.activate!
    end
    if total != 1
      redirect_to session[:return_to] || students_path, notice: "#{total} #{(term_for :student).downcase}(s) have been activated!" and return
    else
      redirect_to session[:return_to] || students_path, notice: "#{total} #{t(term_for :student).downcase}(s) has been activated!" and return
    end
  end

  # Switch between enrolled courses
  def change
    change_current_course params[:id]
    redirect_to root_url
  end

  def recalculate_student_scores
    @course.recalculate_student_scores
    redirect_to root_path, notice: "Recalculated student scores for #{@course.name}"
  end

  def edit_dashboard_message
  end

  def update_dashboard_message
    if current_course.update_attributes(course_params)
      redirect_to dashboard_path, notice: "Course Message successfully updated"
    else
      render action: "edit_dashboard_message"
    end
  end

  def badges
    if @course.has_public_badges?
      @badges = @course.badges
    else
      redirect_to root_path, alert: "Whoops, nothing to see here! That data is not available."
    end
  end

  def syllabus
  end

  def destroy
    authorize! :destroy, @course
    @name = @course.name
    @course.destroy
    redirect_to overview_courses_url, notice: "Course #{@name} successfully deleted"
  end

  private

  def course_params
    course_attrs = [
      :course_number, :name, :semester, :year, :has_badges, :has_teams,
      :has_learning_objectives, :learning_objective_term, :objectives_award_points, :always_show_objectives,
      :team_term, :student_term, :section_leader_term, :group_term, :lti_uid,
      :user_id, :course_id, :course_rules, :dashboard_message, :syllabus, :has_multipliers,
      :has_character_names, :has_team_roles, :has_character_profiles, :show_analytics, :show_grade_predictor,
      :total_weights, :weights_close_at, :has_public_badges,
      :assignment_weight_type, :has_submissions, :teams_visible,
      :weight_term, :fail_term, :pass_term, :time_zone,
      :max_weights_per_assignment_type, :assignments,
      :accepts_submissions, :tagline, :office, :phone,
      :class_email, :twitter_handle, :twitter_hashtag, :location, :office_hours,
      :meeting_times, :assignment_term, :challenge_term, :grade_predictor_term, :badge_term, :gameful_philosophy,
      :team_score_average, :has_team_challenges, :team_leader_term,
      :max_assignment_types_weighted, :full_points, :has_in_team_leaderboards,
      :grade_scheme_elements_attributes, :add_team_score_to_student,
      :assignments_attributes, :start_date, :end_date,
      unlock_conditions_attributes: [:id, :unlockable_id, :unlockable_type, :condition_id,
        :condition_type, :condition_state, :condition_value, :condition_date, :_destroy],
      instructors_of_record_ids: [], course_memberships_attributes: [:id, :course_id, :user_id, :instructor_of_record]
    ]
    if current_user_is_admin?
      params.require(:course).permit(*course_attrs << [:status, :has_paid, :allows_canvas, :allows_learning_objectives, :institution_id, :disable_grade_emails])
    else
      params.require(:course).permit(*course_attrs)
    end
  end

  def find_course
    @course = Course.find(params[:id])
  end

  def change_current_course(intended_course_id)
    if course = current_user.courses.where(id: intended_course_id).first
      authorize! :read, course
      unless session[:course_id] == course.id
        session[:course_id] = CourseRouter.change!(current_user, course).id
        record_course_login_event course: course
      end
    end
  end

  def add_team_score_to_student_changed?
    course_params[:add_team_score_to_student].present? &&
      (@course.add_team_score_to_student != course_params[:add_team_score_to_student])
  end

  def ensure_can_create_courses?
    can_create_courses = current_user_is_admin?
    redirect_to action: :index and return unless can_create_courses
  end
end

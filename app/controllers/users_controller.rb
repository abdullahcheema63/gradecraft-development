require_relative "../importers/user_importers/csv_student_importer"
require_relative "../services/cancels_course_membership"
require_relative "../services/creates_or_updates_user"
require_relative "../services/sends_resource_email"
require 'uri'

# rubocop:disable AndOr
class UsersController < ApplicationController
  include UsersHelper
  include OAuthProvider

  respond_to :html, :json

  before_action :ensure_admin?, only: [:index, :destroy]
  before_action :ensure_app_environment?, only: [:new_external, :create_external]
  before_action :ensure_staff?,
    except: [:activate, :activated, :activated_external, :activate_set_password, :edit_profile, :update_profile, :new_external, :new_external_google, :create_external]
  before_action :save_referer, only: [:manually_activate, :resend_activation_email]
  skip_before_action :require_login, only: [:activate, :activated, :activate_set_password, :new_external, :new_external_google, :create_external, :activated_external]
  skip_before_action :require_course_membership, only: [:activate, :activate_set_password, :activated, :new_external, :new_external_google, :create_external, :activated_external]
  before_action :use_current_course, only: [:import, :upload]

  def index
    @teams = current_course.teams
    @team = @teams.find_by(id: params[:team_id]) if params[:team_id]
    if params[:team_id].present?
      @users = @team.students
      @users << @team.leaders
    else
      @users = current_course.users.where(admin: false).includes(:courses, :teams).order_by_name
    end
  end

  def new
    @user = User.new
    @course_membership = @user.course_memberships.new
    if request.referer.nil?
      @course_membership.role = 'observer'
    else
      case URI(request.referer).path
      when students_path
        @course_membership.role = 'student'
      when staff_index_path
        @course_membership.role = 'gsi'
      else
        @course_membership.role = 'observer'
      end
    end
  end

  # set up the form for users to create their own accounts without being logged
  # into the app
  def new_external
    if current_user.present?
      redirect_to new_user_path
    else
      @user = User.new
    end
  end

  # create a trial account with Google login
  def new_external_google
    session[:activate_google_user] = true
    redirect_to "/auth/google_oauth2/"
  end

  # they've already set their passwords on the page, so they're just sent an
  # email prompting them to activate, and leading them to the next step in the process
  # creating a course
  def create_external
    @user = User.new(user_params.merge(username: user_params[:email]))
    redirect_to new_external_users_path, flash: { error: "Please verify that you are not a robot" } \
      and return if !verify_recaptcha(model: @user)

    if @user.save
      UserMailer.activation_needed_course_creation_email(@user).deliver_now
      redirect_to root_path, notice: "Your account has been created! Please check your email to activate your account."
    else
      render :new_external
    end
  end

  def edit
    @user = User.find(params[:id])
    @course_membership = @user.course_memberships.where(course: current_course).first
  end

  def add_to_team(course, team_name, role)
    return false if !course.has_teams
    return false if team_name.nil?
    return false if team_name.length == 0

    team = Team.find_by(name: team_name, course_id: course.id)

    return false if team.nil?

    if role == "student"
      team.students.push(@user)
    elsif role == "staff"
      team.leaders.push(@user)
    end

    team.save

    return true
  end

  def create
    if user_exists
      result = Services::CreatesOrUpdatesUser.call user_params, current_course,
        params[:send_welcome] == "1"
      @user = result[:user]
      if result.success?
        team_name = user_params["course_memberships_attributes"]["0"]["team_in_course"]
        added_to_team_message = ""

        if @user.is_student?(current_course)
          if add_to_team(current_course, team_name, "student")
            added_to_team_message = "The #{(term_for :student).downcase} #{@user.name} has also been added to the #{(term_for :team).downcase} #{team_name}"
          end

          redirect_to students_path,
            notice: "#{term_for :student} #{@user.name} was successfully created!" + " #{added_to_team_message}" and return
        elsif @user.is_staff?(current_course)
          Services::SendsResourceEmail.call @user

          if add_to_team(current_course, team_name, "staff")
            added_to_team_message = "The staff member #{@user.name} has also been added to the #{(term_for :team).downcase} #{team_name}"
          end

          redirect_to staff_index_path,
            notice: "Staff Member #{@user.name} was successfully created!" + " #{added_to_team_message}" and return
        elsif @user.is_observer?(current_course)
          redirect_to observers_path,
            notice: "Observer #{@user.name} was successfully created!" and return
        end
      end
    else
      @user = User.find_by_insensitive_email(params["user"]["email"])
    end

    if @user.course_memberships.where(course_id: current_course.id).first.nil?
      @course_membership = @user.course_memberships.new
      render :new
    else
      if @user.is_student?(current_course)
        redirect_to students_path,
          alert: "#{term_for :student} #{params["user"]["first_name"]}
            #{params["user"]["last_name"]} with email #{params["user"]["email"]} already exists for #{current_course.name}!" and return
      elsif @user.is_staff?(current_course)
        redirect_to staff_index_path,
          alert: "Staff Member #{params["user"]["first_name"]}
          #{params["user"]["last_name"]} with email #{params["user"]["email"]} already exists for #{current_course.name}!" and return
      elsif @user.is_observer?(current_course)
        redirect_to observers_path,
          alert: "Observer #{params["user"]["first_name"]}
          #{params["user"]["last_name"]} with email #{params["user"]["email"]} already exists for #{current_course.name}!" and return
      end
    end
  end

  def update
    @user = User.find(params[:id])
    user_proctor = UserProctor.new(@user)
    up = user_params
    if (up[:password].blank? && up[:password_confirmation].blank?) || !user_proctor.can_update_password?(current_user, current_course)
      up.delete(:password)
      up.delete(:password_confirmation)
    end
    @user.assign_attributes user_proctor.can_set_email?(current_user, current_course) ? up : up.except(:email)
    cancel_course_memberships @user
    if @user.save
      @user.activate! if up[:password].present? && !@user.activated?
      if @user.is_student?(current_course)
        redirect_to students_path, notice: "#{term_for :student} #{@user.name} was successfully updated!" and return
      elsif @user.is_staff?(current_course)
        redirect_to staff_index_path, notice: "Staff Member #{@user.name} was successfully updated!" and return
      elsif @user.is_observer?(current_course)
        redirect_to observers_path,
          notice: "Observer #{@user.name} was successfully updated!" and return
      end
    end

    @course_membership = @user.course_memberships.where(course: current_course).first
    render action: :edit
  end

  def destroy
    @user = current_course.users.find(params[:id])
    @name = @user.name
    @user.destroy

    respond_to do |format|
      format.html do
        redirect_to users_url,
        notice: "#{@name} was successfully deleted"
      end
    end
  end

  # There are now two forms of activate - the first one just has the activate button
  def activate
    @user = User.load_from_activation_token(params[:id])
    @token = params[:id]
    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user
  end

  # ...and the second form actually has them set a new password. This is where
  # students who are imported/but not at UM are sent to set their info
  def activate_set_password
    @user = User.load_from_activation_token(params[:id])
    @token = params[:id]
    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user
  end

  def manually_activate
    @user = User.find(params[:id])
    @user.activate!

    respond_to do |format|
      format.html { redirect_to session[:return_to] || dashboard_path, notice: "#{@user.first_name} #{@user.last_name} has been activated!" }
      format.json { head :ok }
    end
  end

  def activated
    @token = params[:token]
    @user = User.load_from_activation_token(@token)

    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user

    if @user.update_attributes user_params
      @user.activate!
      auto_login @user
      @user.update_login_at
      redirect_to dashboard_path, notice: "Welcome to GradeCraft!" and return
    end
    render :activate, alert: @user.errors.full_messages.first
  end

  # This is step #2 in the process of external users creating course shells - they
  # activate their account and then are sent on to a very basic Create a Course
  # form.
  def activated_external
    @token = params[:token]
    @user = User.load_from_activation_token(@token)

    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user

    if @user.save
      @user.activate!
      UserMailer.app_resources_email(@user).deliver_now
      redirect_to new_external_courses_path(user_id: @user.id), notice: "Welcome to GradeCraft!" and return
    end
    render :activate, alert: @user.errors.full_messages.first
  end

  def flag
    @user = User.find(params[:id])

    FlaggedUser.toggle! current_course, current_user, @user.id

    respond_to do |format|
      format.js
      format.json do
        render json: { flagged: FlaggedUser.flagged?(current_course, current_user, @user.id), success: true },
          status: :ok
      end
    end
  end

  # We don't allow students to edit their info directly
  def edit_profile
    @user = current_user
    @course_membership =
      @user.course_memberships.where(course_id: current_course).first
  end

  def update_profile
    @user = current_user

    up = user_params
    if up[:password].blank? && up[:password_confirmation].blank?
      up.delete(:password)
      up.delete(:password_confirmation)
    end

    if @user.update_attributes(up)
      redirect_to dashboard_path,
        notice: "Your profile was successfully updated!"
    else
      @course_membership =
        @user.course_memberships.where(course_id: current_course).first
      render :edit_profile
    end
  end

  def import
    redirect_to users_importers_path unless current_user_is_admin? || accessible_to_app_env?
  end

  # import users for class
  def upload
    if params[:file].blank?
      flash[:notice] = "File missing"
      redirect_to action: :import and return
    end

    if (File.extname params[:file].original_filename) != ".csv"
      redirect_to users_path, notice: "We're sorry, the user import utility only supports .csv files. Please try again using a .csv file." and return
    end

    @result = CSVStudentImporter.new(params[:file].tempfile,
                                     current_course,
                                     params[:internal_students] == "1",
                                     params[:send_welcome] == "1")
      .import
    render :import_results
  end

  # resend invite email
  def resend_activation_email
    @user = User.find(params[:id])
    @user.setup_activation
    @user.save
    UserMailer.activation_needed_email(@user).deliver_now
    redirect_to session[:return_to] || dashboard_path, notice: "An Activation Email has been sent to #{@user.name}!"
  end

  def search
    @q = User.ransack params[:q]

    unless params[:q].nil?
      @result_size = @q.result.count
      @users = @q.result.includes(:course_memberships).limit(params[:max_results] || 50)
    end
  end

  private

  def user_exists
    if User.find_by_insensitive_email(params["user"]["email"]).nil?
      return true
    end

    user = User.find_by_insensitive_email(params["user"]["email"])

    if user.course_memberships.where(course_id: params["user"]["course_memberships_attributes"]["0"]["course_id"]).empty?
      return true
    end

    return false
  end

  def user_params
    params.require(:user).permit :username, :email, :password, :time_zone, :password_confirmation, :activation_token_expires_at, :activation_token,
      :activation_state, :avatar_file_name, :first_name, :last_name, :user_id,
      :kerberos_uid, :display_name, :current_course_id, :last_activity_at, :reset_password_email_sent_at, :reset_password_token_expires_at, :reset_password_token,
      :remove_avatar_file_name, :last_login_at, :last_logout_at, :team_ids, :course_ids, :remember_me_token_expires_at,
      :remember_me_token, :team_role, :team_id, :lti_uid, :course_team_ids, :internal,
      earned_badges_attributes: [:points, :feedback, :student_id, :badge_id,
        :submission_id, :course_id, :assignment_id, :level_id, :criterion_id, :grade_id,
        :student_visible, :id, :_destroy],
      course_memberships_attributes: [:auditing, :pseudonym, :character_profile, :team_in_course, :course_id,
        :instructor_of_record, :user_id, :role, :last_login_at, :id, :team_role, :email_announcements,
        :email_badge_awards, :email_grade_notifications, :email_challenge_grade_notifications,
        :email_learning_objective_achieved, :_destroy]
  end
end

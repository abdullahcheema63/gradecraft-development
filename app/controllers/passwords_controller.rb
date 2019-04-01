class PasswordsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership

  # rubocop:disable AndOr

  def create
    @user = User.find_by_insensitive_email(params[:email])
    @user.deliver_reset_password_instructions! if @user

    redirect_to root_path,
      notice: "Password reset instructions have been sent to your email."
  end

  def edit
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    redirect_to root_path,
      alert: "Invalid or expired password reset token. Please request new password reset instructions." and return unless @user
  end

  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    redirect_to root_path,
      alert: "Invalid or expired password reset token. Please request new password reset instructions." and return unless @user

    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password!(params[:user][:password])
      @user.activate! unless @user.activated?
      auto_login @user
      @user.update_login_at
      redirect_to dashboard_path,
        notice: "Password was successfully updated" and return
    end
    redirect_to edit_password_path, id: @token, alert: @user.errors.full_messages.first
  end
end

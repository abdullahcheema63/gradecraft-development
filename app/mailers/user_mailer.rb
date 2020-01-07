class UserMailer < ApplicationMailer
  layout "mailers/notification_layout"

  track extra: -> { {course_id: @user.current_course.id } if @user.current_course }
  track open: true, click: true # use only/except to limit actions

  def activation_needed_email(user)
    @user = user
    mail to: @user.email,
         subject: "Welcome to GradeCraft! Please activate your account"
  end

  def activation_needed_course_creation_email(user)
    @user = user
    mail to: @user.email,
         subject: "Welcome to GradeCraft! Please activate your account"
  end

  def reset_password_email(user)
    @user = user
    mail(to: user.email, subject: "Your GradeCraft Password Reset Instructions")
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to GradeCraft!")
  end

  def umich_resources_email(user)
    @user = user
    mail(to: @user.email, subject: "GradeCraft Resources!")
  end

  def app_resources_email(user)
    @user = user
    mail(to: @user.email, subject: "GradeCraft Resources!")
  end
end

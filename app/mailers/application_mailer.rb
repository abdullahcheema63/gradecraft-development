class ApplicationMailer < ActionMailer::Base
  SENDER_EMAIL = "mailer@gradecraft.com"
  ADMIN_EMAIL = "admin@gradecraft.com"
  ADMIN_GROUP_EMAIL = "gradecraft-admins@umich.edu"
  SENDER = "GradeCraft <#{SENDER_EMAIL}>"

  default from: SENDER

  track extra: -> { {course_id: @course.id} }
  track open: true, click: true # use only/except to limit actions

end

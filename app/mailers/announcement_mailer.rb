class AnnouncementMailer < ApplicationMailer
  layout "mailers/notification_layout"
  track extra: -> { {course_id: @announcement.course.id } }
  track open: true, click: true # use only/except to limit actions

  def announcement_email(announcement, student)
    @announcement = announcement
    @student = student
    @email_title = "GradeCraft Announcement"

    mail to: @student.email,
       from: "\"#{@announcement.author.name}\" <#{@announcement.author.email}>",
    subject: @announcement.title
  end
end

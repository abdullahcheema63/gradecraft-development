require "sidekiq-scheduler"

class UnpublishExpiredSubscribedCoursesJob
  include Sidekiq::Worker

  def perform
    expired_subscriptions = Subscription.expired

    expired_subscriptions.each do |subscription|
      if(DateTime.current >= subscription.end_of_grace_period) && subscription.courses.any?
        course_ids = subscription.course_ids
        courses = subscription.courses
        subscription.unsubscribe_courses(course_ids)
        subscription.abandon_last_payment
        puts "subscription before NotificationMailer: ", subscription.inspect
        NotificationMailer.unpublished_courses(courses, subscription).deliver_now
      end
    end

    #Notify admin's of the courses that were unpublished, maybe create csv
      # during the loop above to generate just one email for the admins?

  end
end

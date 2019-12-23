require "sidekiq-scheduler"

class UnpublishExpiredSubscribedCoursesJob
  include Sidekiq::Worker

  def perform
    expired_subscriptions = Subscription.expired

    # Thinking we could add a `grace_period` variable to the subscription to check
    # within this method in case we ever allow users to set when their renewal date is

    expired_subscriptions.each do |subscription|
      course_ids = subscription.course_ids
      courses = subscription.courses
      subscription.unsubscribe_courses(course_ids)

      NotificationMailer.unpublished_courses(courses, subscription).deliver_now
    end

    #Notify admin's of the courses that were unpublished, maybe create csv
      # during the loop above to generate just one email for the admins? 

  end
end

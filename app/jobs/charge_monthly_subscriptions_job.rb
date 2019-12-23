require "sidekiq-scheduler"

class ChargeMonthlySubscriptionsJob
  include Sidekiq::Worker

  def perform
    expired_subscriptions = Subscription.expired

    expired_subscriptions.each do |subscription|
      subscription.initiate_off_session_payment
    end
  end
end

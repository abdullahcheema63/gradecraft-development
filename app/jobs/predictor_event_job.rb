class PredictorEventJob
  include Sidekiq::Worker
  sidekiq_options retry: 10, queue: 'low'

  def perform(data)
  end
end

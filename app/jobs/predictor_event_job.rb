class PredictorEventJob
  include Sidekiq::Worker
  sidekiq_options retry: 10, queue: 'low'

  def perform(data)
    Analytics::Event.create({ event_type: "predictor" }.merge(data))
  end
end

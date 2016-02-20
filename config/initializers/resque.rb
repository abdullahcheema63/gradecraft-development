require "resque"
require "resque/throttler" # throttles number of jobs being run in a queue at a time
require "resque-retry" # retries failed/exceptioned jobs
require "resque/failure/redis"

REDIS = Redis.new(:host =>  ENV["REDIS_HOST_IP"], :port => ENV["REDIS_PORT"])
Resque.redis = REDIS

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

# rate limits by queue
Resque.rate_limit(:pageview_event_logger, at: 20, :per => 1) # process 2 jobs/second max
Resque.rate_limit(:login_event_logger, at: 5, :per => 2) # process 2 jobs/second max

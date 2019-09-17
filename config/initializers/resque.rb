require "resque"
require "rollbar"
# throttles number of jobs being run in a queue at a time
require "resque/throttler"
require "resque-retry" # retries failed/exceptioned jobs
require "resque-retry/server"
require "resque/failure/redis"
require "resque/server"
require "resque-scheduler"
require "resque/scheduler/server"

REDIS = Redis.new(host: ENV["REDIS_HOST_IP"], port: ENV["REDIS_PORT"])
Resque.redis = REDIS

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis, Resque::Failure::Rollbar]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

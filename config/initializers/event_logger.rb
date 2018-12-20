EventLogger.configure do |config|
  # retries max 10 times @ 0s, 15s, 30s, 1m, 2m, 5m, 10m, 1h, 3h, 6h intervals
  config.backoff_strategy = [0, 15, 30, 60, 120, 300, 600, 3600, 10800, 21600]

  # config.backoff_strategy = [
  #   0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780,
  #   900, 1_140, 1_380, 1_520, 1_760, 3_600, 7_200, 14_400, 28_800
  # ]
end

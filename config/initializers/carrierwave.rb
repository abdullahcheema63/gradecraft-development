CarrierWave.configure do |config|

  # Use local storage if in development or test
  if Rails.env.development? || Rails.env.test?
    CarrierWave.configure do |config|
      config.storage = :file
    end
  end

  # Use AWS storage if in production
  if Rails.env.production?
   CarrierWave.configure do |config|
     config.storage = :file
   end
  end

  config.fog_provider = "fog/aws"
  config.fog_credentials = {
    :provider               => "AWS",
    :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key  => ENV["AWS_SECRET_ACCESS_KEY"]
  }
  config.fog_directory = ENV["AWS_S3_BUCKET"] || "gradecraft-#{Rails.env}"
  config.fog_public = true
end

ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "spec/*"
    add_filter "app/helpers/color_palette_helper.rb"
    add_filter "config/*"
    add_filter "app/mailer_previews/*"
  end
end

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "paper_trail"
require "paper_trail/frameworks/rspec"
require "capybara/rspec"
require "rails-controller-testing"
require "sidekiq/testing"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/toolkits/**/*.rb")].each { |f| require f }
Dir["./app/services/*.rb"].each { |f| require f }
Dir["./app/uploaders/*.rb"].each { |f| require f }
Dir["./app/validators/*.rb"].each { |f| require f }
Dir["./app/proctors/*.rb"].each { |f| require f }
Dir["./app/models/concerns/*.rb"].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
# ActiveRecord::Migration.maintain_test_schema!

FactoryBot::SyntaxRunner.send(:include, FileHelpers)

Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.include FileHelpers

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.before(:suite) do
    begin
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      FactoryBot.factories.clear
      FactoryBot.find_definitions
      # Enable external API access unless it is explicitly turned off with api_spec_helper
      WebMock.allow_net_connect!
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include FactoryBot::Syntax::Methods

  config.include ::Rails::Controller::Testing::TestProcess, type: :controller
  config.include ::Rails::Controller::Testing::TemplateAssertions, type: :controller
  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
  config.include GradeCraft::Matchers::Integration, type: :feature
  config.include GradeCraft::Integration::TestHelpers::Authentication, type: :feature

  config.tty = true

  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.infer_spec_type_from_file_location!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false # THIS IS DIFFERENT FROM THE BASE SPEC HELPER. TODO: GET ALIGNED
  end

  # Remove uploader files, see config/environments/test.rb
  config.after(:all) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/*"])
  end
end

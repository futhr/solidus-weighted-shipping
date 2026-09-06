# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] = "test"

project_root = File.expand_path("..", __dir__)
dummy_root = File.expand_path(ENV.fetch("DUMMY_PATH", "spec/dummy"), project_root)
dummy_environment = File.join(dummy_root, "config/environment.rb")
unless File.exist?(dummy_environment)
  system(File.join(project_root, "bin/rake"), "extension:test_app") || abort("Test application creation failed")
end
require dummy_environment

ActiveRecord::Migration.maintain_test_schema!

require "solidus_dev_support/rspec/feature_helper"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |file| require file }

Rails.application.routes.append do
  get "/weighted-shipping-preview/:order_id",
    to: "solidus_weighted_shipping/test_preview#show"
end
Rails.application.reload_routes!

SolidusDevSupport::TestingSupport::Factories.load_for(SolidusWeightedShipping::Engine)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false
end

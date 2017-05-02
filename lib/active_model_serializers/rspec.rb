require 'active_model_serializers/rspec_matchers/schema'

RSpec.configure do |config|
  config.include ActiveModelSerializers::RSpecMatchers::Schema, type: :request
  config.include ActiveModelSerializers::RSpecMatchers::Schema, type: :controller
end

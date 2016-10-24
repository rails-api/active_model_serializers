require 'active_model_serializers/test/schema'

module ActiveModelSerializers
  module RSpecMatchers
    module Schema
      RSpec::Matchers.define :have_valid_schema do |schema_path|
        match do
          @matcher = ActiveModelSerializers::Test::Schema::AssertSchema.new(
            schema_path || nil, request, response, nil
          )
          @matcher.call
        end

        failure_message do
          @matcher.message
        end
      end
    end
  end
end

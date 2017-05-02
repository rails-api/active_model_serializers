require 'active_model_serializers/test/schema'

module ActiveModelSerializers
  module RSpecMatchers
    module Schema
      RSpec::Matchers.define :have_valid_schema do
        chain :at_path do |schema_path|
          @schema_path = schema_path
        end

        match do
          @matcher = ActiveModelSerializers::Test::Schema::AssertSchema.new(
            @schema_path, request, response, nil
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

require 'active_model_serializers/test/schema'

module ActiveModelSerializers
  module RSpecMatchers
    module Schema
      extend ActiveSupport::Concern

      included do
        RSpec::Matchers.define :have_valid_schema do |schema_path|
          match do
            @matcher = Base.new(schema_path || nil, request, response, nil)
            @matcher.call
          end
          failure_message do
            @matcher.message
          end
        end
      end

      class Base < ActiveModelSerializers::Test::Schema::AssertSchema
        def controller_path
          request.filtered_parameters.with_indifferent_access[:controller]
        end

        def action
          request.filtered_parameters.with_indifferent_access[:action]
        end
      end
    end
  end
end

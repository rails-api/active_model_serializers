require 'test_helper'

module ActionController
  module Serialization
    class JsonApiIntegrationTest < ActionController::TestCase
      class JsonApiIntegrationTestController < ActionController::Base
      end

      tests JsonApiIntegrationTestController

      def test_json_api_deserialization_on_create_without_relationships
      end
    end
  end
end

require 'test_helper'

module ActionController
  module Serialization
    class OverrideSerializationScopeTest < ActionController::TestCase

      class OverrideSerializationScopeController < ActionController::Base
        serialization_scope :admin

        def index
          render json: [InternalsTester.new]
        end

        def show
          render json: InternalsTester.new
        end

        private

        def admin
          'admin'
        end

        def default_serializer_options
          { root: false }
        end
      end

      tests OverrideSerializationScopeController

      def test_override_serialization_scope_index
        get :index
        assert_equal '[{"serialization_scope":"admin"}]', @response.body
      end

      def test_override_serialization_scope_show
        get :show
        assert_equal '{"serialization_scope":"admin"}', @response.body
      end
    end
  end
end

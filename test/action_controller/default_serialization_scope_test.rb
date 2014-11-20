require 'test_helper'

module ActionController
  module Serialization
    class DefaultSerializationScopeTest < ActionController::TestCase

      class DefaultSerializationScopeController < ActionController::Base
        def index
          render json: [InternalsTester.new]
        end

        def show
          render json: InternalsTester.new
        end

        private

        def current_user
          'current_user'
        end

        def default_serializer_options
          { root: true }
        end
      end

      tests DefaultSerializationScopeController

      def test_serialization_scope_index
        get :index
        assert_equal '{"internals_testers":[{"internals_tester":{"serialization_scope":"current_user"}}]}', @response.body
      end

      def test_serialization_scope_show
        get :show
        assert_equal '{"internals_tester":{"serialization_scope":"current_user"}}', @response.body
      end
    end
  end
end

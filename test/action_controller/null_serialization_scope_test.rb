require 'test_helper'

module ActionController
  module Serialization
    class NullSerializationScopeTest < ActionController::TestCase

      class NullSerializationScopeController < ActionController::Base
        serialization_scope nil

        def index
          render json: [InternalsTester.new]
        end

        def show
          render json: InternalsTester.new
        end
      end

      tests NullSerializationScopeController

      def test_null_serialization_scope_index
        get :index
        assert_equal '[{"serialization_scope":null}]', @response.body
      end

      def test_null_serialization_scope_show
        get :show
        assert_equal '{"serialization_scope":null}', @response.body
      end
    end
  end
end

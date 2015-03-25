require 'test_helper'

module ActionController
  module Serialization
    class PrimitiveSerializationTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_array_of_primitives
          render json: ['value1', 1, {some: 'hash'}]
        end
      end

      tests MyController

      def test_render_array_of_primitives
        get :render_array_of_primitives

        assert_equal 'application/json', @response.content_type
        assert_equal %{["value1",1,{"some":"hash"}]}, @response.body
      end
    end
  end
end

require 'test_helper'

module ActionController
  module Serialization
    class RescueFromTest < ActionController::TestCase
      class MyController < ActionController::Base
        rescue_from Exception, with: :handle_error

        def render_using_raise_error_serializer
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: [@profile], serializer: RaiseErrorSerializer
        end

        def handle_error(exception)
          render json: { errors: ['Internal Server Error'] }, status: :internal_server_error
        end
      end

      tests MyController

      def test_rescue_from
        get :render_using_raise_error_serializer

        expected = {
          errors: ['Internal Server Error']
        }.to_json

        assert_equal expected, @response.body
      end
    end
  end
end

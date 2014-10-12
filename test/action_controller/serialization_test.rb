require 'test_helper'

module ActionController
  module Serialization
    class ImplicitSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_implicit_serializer
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        def render_array_using_implicit_serializer
          array = [
            Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
            Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
          ]
          render json: array
        end
      end

      tests MyController

      # We just have Null for now, this will change
      def test_render_using_implicit_serializer
        get :render_using_implicit_serializer

        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1"}', @response.body
      end

      def test_render_array_using_implicit_serializer
        get :render_array_using_implicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = [
          {
            name: 'Name 1',
            description: 'Description 1',
          },
          {
            name: 'Name 2',
            description: 'Description 2',
          }
        ]

        assert_equal expected.to_json, @response.body
      end
    end
  end
end

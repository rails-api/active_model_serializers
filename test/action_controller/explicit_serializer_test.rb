require 'test_helper'

module ActionController
  module Serialization
    class ExplicitSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_explicit_serializer
          @profile = Profile.new(name: 'Name 1',
                                 description: 'Description 1',
                                 comments: 'Comments 1')
          render json: @profile, serializer: ProfilePreviewSerializer
        end

        def render_array_using_explicit_serializer
          array = [
            Profile.new(name: 'Name 1',
                        description: 'Description 1',
                        comments: 'Comments 1'),
            Profile.new(name: 'Name 2',
                        description: 'Description 2',
                        comments: 'Comments 2')
          ]
          render json: array,
                 serializer: PaginatedSerializer,
                 each_serializer: ProfilePreviewSerializer
        end

        def render_array_using_implicit_serializer
          array = [
            Profile.new(name: 'Name 1',
                        description: 'Description 1',
                        comments: 'Comments 1'),
            Profile.new(name: 'Name 2',
                        description: 'Description 2',
                        comments: 'Comments 2')
          ]
          render json: array,
                 each_serializer: ProfilePreviewSerializer
        end
      end

      tests MyController

      def test_render_using_explicit_serializer
        get :render_using_explicit_serializer

        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1"}', @response.body
      end

      def test_render_array_using_explicit_serializer
        get :render_array_using_explicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = {
          'paginated' => [
            { 'name' => 'Name 1' },
            { 'name' => 'Name 2' }
          ]
        }

        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_explicit_serializer
        get :render_array_using_implicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = [
          { 'name' => 'Name 1' },
          { 'name' => 'Name 2' }
        ]
        assert_equal expected.to_json, @response.body
      end

    end
  end
end

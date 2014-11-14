require 'test_helper'

module ActionController
  module Serialization
    class ImplicitSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_implicit_serializer
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile
        end

        def render_using_custom_root
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile, root: "custom_root"
        end

        def render_using_default_adapter_root
          old_adapter = ActiveModel::Serializer.config.adapter
          # JSON-API adapter sets root by default
          ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile
        ensure
          ActiveModel::Serializer.config.adapter = old_adapter
        end

        def render_using_custom_root_in_adapter_with_a_default
          # JSON-API adapter sets root by default
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile, root: "profile", adapter: :json_api
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

      def test_render_using_custom_root
        get :render_using_custom_root

        assert_equal 'application/json', @response.content_type
        assert_equal '{"custom_root":{"name":"Name 1","description":"Description 1"}}', @response.body
      end

      def test_render_using_default_root
        get :render_using_default_adapter_root

        assert_equal 'application/json', @response.content_type
        assert_equal '{"profiles":{"name":"Name 1","description":"Description 1"}}', @response.body
      end

      def test_render_using_custom_root_in_adapter_with_a_default
        get :render_using_custom_root_in_adapter_with_a_default

        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1"}}', @response.body
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

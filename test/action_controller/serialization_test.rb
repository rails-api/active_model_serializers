require 'test_helper'

module ActionController
  module Serialization
    class ImplicitSerializerTest < ActionController::TestCase
      class ImplicitSerializationTestController < ActionController::Base
        include SerializationTesting
        def render_using_implicit_serializer
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: @profile
        end

        def render_using_default_adapter_root
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: @profile
        end

        def render_array_using_custom_root
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: [@profile], root: 'custom_root'
        end

        def render_array_that_is_empty_using_custom_root
          render json: [], root: 'custom_root'
        end

        def render_object_using_custom_root
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: @profile, root: 'custom_root'
        end

        def render_array_using_implicit_serializer
          array = [
            Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1'),
            Profile.new(name: 'Name 2', description: 'Description 2', comments: 'Comments 2')
          ]
          render json: array
        end

        def render_array_using_implicit_serializer_and_meta
          @profiles = [
            Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          ]
          render json: @profiles, meta: { total: 10 }
        end

        def render_array_using_implicit_serializer_and_links
          with_adapter ActiveModelSerializers::Adapter::JsonApi do
            @profiles = [
              Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
            ]

            render json: @profiles, links: { self: 'http://example.com/api/profiles/1' }
          end
        end

        def render_json_object_without_serializer
          render json: { error: 'Result is Invalid' }
        end

        def render_json_array_object_without_serializer
          render json: [{ error: 'Result is Invalid' }]
        end
      end

      tests ImplicitSerializationTestController

      # We just have Null for now, this will change
      def test_render_using_implicit_serializer
        get :render_using_implicit_serializer

        expected = {
          name: 'Name 1',
          description: 'Description 1'
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_using_default_root
        with_adapter :json_api do
          get :render_using_default_adapter_root
        end
        expected = {
          data: {
            id: @controller.instance_variable_get(:@profile).id.to_s,
            type: 'profiles',
            attributes: {
              name: 'Name 1',
              description: 'Description 1'
            }
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_custom_root
        with_adapter :json do
          get :render_array_using_custom_root
        end
        expected = { custom_root: [{ name: 'Name 1', description: 'Description 1' }] }
        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_that_is_empty_using_custom_root
        with_adapter :json do
          get :render_array_that_is_empty_using_custom_root
        end

        expected = { custom_root: [] }
        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_object_using_custom_root
        with_adapter :json do
          get :render_object_using_custom_root
        end

        expected = { custom_root: { name: 'Name 1', description: 'Description 1' } }
        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_json_object_without_serializer
        get :render_json_object_without_serializer

        assert_equal 'application/json', @response.content_type
        expected_body = { error: 'Result is Invalid' }
        assert_equal expected_body.to_json, @response.body
      end

      def test_render_json_array_object_without_serializer
        get :render_json_array_object_without_serializer

        assert_equal 'application/json', @response.content_type
        expected_body = [{ error: 'Result is Invalid' }]
        assert_equal expected_body.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer
        get :render_array_using_implicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = [
          {
            name: 'Name 1',
            description: 'Description 1'
          },
          {
            name: 'Name 2',
            description: 'Description 2'
          }
        ]

        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer_and_meta
        with_adapter :json_api do
          get :render_array_using_implicit_serializer_and_meta
        end
        expected = {
          data: [
            {
              id: @controller.instance_variable_get(:@profiles).first.id.to_s,
              type: 'profiles',
              attributes: {
                name: 'Name 1',
                description: 'Description 1'
              }
            }
          ],
          meta: {
            total: 10
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer_and_links
        get :render_array_using_implicit_serializer_and_links

        expected = {
          data: [
            {
              id: @controller.instance_variable_get(:@profiles).first.id.to_s,
              type: 'profiles',
              attributes: {
                name: 'Name 1',
                description: 'Description 1'
              }
            }
          ],
          links: {
            self: 'http://example.com/api/profiles/1'
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_warn_overridding_use_adapter_as_falsy_on_controller_instance
        controller = Class.new(ImplicitSerializationTestController) do
          def use_adapter?
            false
          end
        end.new
        assert_output(nil, /adapter: false/) do
          controller.get_serializer(Profile.new)
        end
      end

      def test_dont_warn_overridding_use_adapter_as_truthy_on_controller_instance
        controller = Class.new(ImplicitSerializationTestController) do
          def use_adapter?
            true
          end
        end.new
        assert_output(nil, '') do
          controller.get_serializer(Profile.new)
        end
      end

      def test_render_event_is_emmited
        subscriber = ::ActiveSupport::Notifications.subscribe('render.active_model_serializers') do |name|
          @name = name
        end

        get :render_using_implicit_serializer

        assert_equal 'render.active_model_serializers', @name
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      end
    end
  end
end

require 'test_helper'

module ActionController
  module Serialization
    class AdapterSelectorTest < ActionController::TestCase
      class AdapterSelectorTestController < ActionController::Base
        def render_using_default_adapter
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile
        end

        def render_using_adapter_override
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile, adapter: :json_api
        end

        def render_skipping_adapter
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile, adapter: false
        end

        def render_selecting_adapter_by_accept_header_field
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          render json: @profile
        end
      end

      tests AdapterSelectorTestController

      def test_render_using_default_adapter
        get :render_using_default_adapter
        assert_equal '{"name":"Name 1","description":"Description 1"}', response.body
      end

      def test_render_using_adapter_override
        get :render_using_adapter_override

        expected = {
          data: {
            id: assigns(:profile).id.to_s,
            type: "profiles",
            attributes: {
              name: "Name 1",
              description: "Description 1",
            }
          }
        }

        assert_equal expected.to_json, response.body
      end

      def test_render_skipping_adapter
        get :render_skipping_adapter
        assert_equal '{"attributes":{"name":"Name 1","description":"Description 1","comments":"Comments 1"}}', response.body
      end

      def test_render_using_adapter_selected_by_accept_header_field
        ActiveModel::Serializer.config.enabled_adapters_by_media_type = true
        request.headers['Accept'] = "application/vnd.api+json"

        get :render_selecting_adapter_by_accept_header_field

        expected = {
          data: {
            id: assigns(:profile).id.to_s,
            type: "profiles",
            attributes: {
              name: "Name 1",
              description: "Description 1",
            }
          }
        }

        assert_equal expected.to_json, response.body
      end

    end
  end
end

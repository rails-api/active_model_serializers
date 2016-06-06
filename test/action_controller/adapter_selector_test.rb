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
            id: @controller.instance_variable_get(:@profile).id.to_s,
            type: 'profiles',
            attributes: {
              name: 'Name 1',
              description: 'Description 1'
            }
          }
        }

        assert_equal expected.to_json, response.body
      end

      def test_render_skipping_adapter
        get :render_skipping_adapter
        assert_equal '{"name":"Name 1","description":"Description 1","comments":"Comments 1"}', response.body
      end
    end
  end
end

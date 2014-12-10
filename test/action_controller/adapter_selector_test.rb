require 'test_helper'

module ActionController
  module Serialization
    class AdapterSelectorTest < ActionController::TestCase
      class MyController < ActionController::Base
        include ActionController::Serialization
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

      tests MyController

      def test_render_using_default_adapter
        get :render_using_default_adapter
        assert_equal '{"name":"Name 1","description":"Description 1"}', response.body
      end

      def test_render_using_adapter_override
        get :render_using_adapter_override
        assert_equal '{"profiles":{"name":"Name 1","description":"Description 1"}}', response.body
      end

      def test_render_skipping_adapter
        get :render_skipping_adapter
        assert_equal '{"attributes":{"name":"Name 1","description":"Description 1","comments":"Comments 1"}}', response.body
      end
    end
  end
end

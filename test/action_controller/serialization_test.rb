require 'test_helper'

module ActionController
  module Serialization
    class ImplicitSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_implicit_serializer
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end
      end

      tests MyController

      # We just have Null for now, this will change
      def test_render_using_implicit_serializer
        get :render_using_implicit_serializer

        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1"}', @response.body
      end
    end

    class ImplicitSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_implicit_serializer_and_scope
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end
      end

      tests MyController

      def test_redner_using_implicit_serializer_and_scope
        get :render_using_implicit_serializer_and_scope

        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1 - current_user"}', @response.body
      end
    end

    class DefaultOptionsForSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def default_serializer_options
          { scope: current_admin }
        end

        def render_using_scope_set_in_default_serializer_options
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end

        def current_admin
          'current_admin'
        end
      end

      tests MyController

      def test_render_using_scope_set_in_default_serializer_options
        get :render_using_scope_set_in_default_serializer_options
        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1 - current_admin"}', @response.body
      end
    end
  end
end

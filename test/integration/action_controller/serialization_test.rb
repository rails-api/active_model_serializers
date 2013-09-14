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

      def test_render_using_implicit_serializer_and_scope
        get :render_using_implicit_serializer_and_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1 - current_user"}', @response.body
      end
    end

    class ExplicitSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_implicit_serializer_and_explicit_scope
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }), scope: current_admin
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

      def test_render_using_implicit_serializer_and_explicit_scope
        get :render_using_implicit_serializer_and_explicit_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1 - current_admin"}', @response.body
      end
    end

    class OverridingSerializationScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_overriding_serialization_scope
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end

        def serialization_scope
          'current_admin'
        end
      end

      tests MyController

      def test_render_overriding_serialization_scope
        get :render_overriding_serialization_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1 - current_admin"}', @response.body
      end
    end

    class CallingSerializationScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_calling_serialization_scope
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end

        serialization_scope :current_user
      end

      tests MyController

      def test_render_calling_serialization_scope
        get :render_calling_serialization_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1","description":"Description 1 - current_user"}', @response.body
      end
    end

    class RailsSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_rails_behavior
          render json: JSON.dump(hello: 'world')
        end
      end

      tests MyController

      def test_render_using_rails_behavior
        get :render_using_rails_behavior
        assert_equal 'application/json', @response.content_type
        assert_equal '{"hello":"world"}', @response.body
      end
    end
  end
end

require 'test_helper'

module ActionController
  module JsonSerialization
    class ImplicitSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_using_implicit_serializer
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end
      end

      tests MyController

      def test_render_json_using_implicit_serializer
        get :render_json_using_implicit_serializer
        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1"}}', @response.body
      end
    end

    class ImplicitSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_using_implicit_serializer_and_scope
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end
      end

      tests MyController

      def test_render_json_using_implicit_serializer_and_scope
        get :render_json_using_implicit_serializer_and_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1 - current_user"}}', @response.body
      end
    end

    class DefaultOptionsForSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def default_serializer_options
          { scope: current_admin }
        end

        def render_json_using_scope_set_in_default_serializer_options
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

      def test_render_json_using_scope_set_in_default_serializer_options
        get :render_json_using_scope_set_in_default_serializer_options
        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1 - current_admin"}}', @response.body
      end
    end

    class ExplicitSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_using_implicit_serializer_and_explicit_scope
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

      def test_render_json_using_implicit_serializer_and_explicit_scope
        get :render_json_using_implicit_serializer_and_explicit_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1 - current_admin"}}', @response.body
      end
    end

    class OverridingSerializationScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_overriding_serialization_scope
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

      def test_render_json_overriding_serialization_scope
        get :render_json_overriding_serialization_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1 - current_admin"}}', @response.body
      end
    end

    class CallingSerializationScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_calling_serialization_scope
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end

        serialization_scope :current_user
      end

      tests MyController

      def test_render_json_calling_serialization_scope
        get :render_json_calling_serialization_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"profile":{"name":"Name 1","description":"Description 1 - current_user"}}', @response.body
      end
    end

    class JSONDumpSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_json_dump
          render json: JSON.dump(hello: 'world')
        end
      end

      tests MyController

      def test_render_using_json_dump
        get :render_using_json_dump
        assert_equal 'application/json', @response.content_type
        assert_equal '{"hello":"world"}', @response.body
      end
    end

    class RailsSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_using_rails_behavior
          render json: [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })], serializer: false
        end
      end

      tests MyController

      def test_render_json_using_rails_behavior
        get :render_json_using_rails_behavior
        assert_equal 'application/json', @response.content_type
        assert_equal '[{"attributes":{"name":"Name 1","description":"Description 1","comments":"Comments 1"}}]', @response.body
      end
    end

    class ArraySerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_json_array
          render json: [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })]
        end
      end

      tests MyController

      def test_render_json_array
        get :render_json_array
        assert_equal 'application/json', @response.content_type
        assert_equal '{"my":[{"name":"Name 1","description":"Description 1"}]}', @response.body
      end
    end

    class ArrayEmbedingSerializerTest < ActionController::TestCase
      def setup
        super
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup
      end

      def teardown
        super
        UserSerializer._associations[:profile] = @old_association
      end

      class MyController < ActionController::Base
        def initialize(*)
          super
          @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        end
        attr_reader :user

        def render_array_embeding_in_root
          render json: [@user]
        end
      end

      tests MyController

      def test_render_array_embeding_in_root
        @association.embed = :ids
        @association.embed_in_root = true

        get :render_array_embeding_in_root
        assert_equal 'application/json', @response.content_type

        assert_equal("{\"my\":[{\"name\":\"Name 1\",\"email\":\"mail@server.com\",\"profile_id\":#{@controller.user.profile.object_id}}],\"profiles\":[{\"name\":\"N1\",\"description\":\"D1\"}]}", @response.body)
      end
    end

  end
end

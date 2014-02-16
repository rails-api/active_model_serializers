require 'test_helper'

module ActionController
  module XmlSerialization
    class ImplicitSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_xml_using_implicit_serializer
          render xml: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end
      end

      tests MyController

      def test_render_xml_using_implicit_serializer
        get :render_xml_using_implicit_serializer
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profile><name>Name 1</name><description>Description 1</description></profile>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class ImplicitSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_xml_using_implicit_serializer_and_scope
          render xml: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end
      end

      tests MyController

      def test_render_xml_using_implicit_serializer
        get :render_xml_using_implicit_serializer_and_scope
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profile><name>Name 1</name><description>Description 1 - current_user</description></profile>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class DefaultOptionsForSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def default_serializer_options
          { scope: current_admin }
        end

        def render_xml_using_scope_set_in_default_serializer_options
          render xml: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
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

      def test_render_xml_using_scope_set_in_default_serializer_options
        get :render_xml_using_scope_set_in_default_serializer_options
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profile><name>Name 1</name><description>Description 1 - current_admin</description></profile>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class ExplicitSerializerScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_xml_using_implicit_serializer_and_explicit_scope
          render xml: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }), scope: current_admin
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

      def test_render_xml_using_implicit_serializer_and_explicit_scope
        get :render_xml_using_implicit_serializer_and_explicit_scope
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profile><name>Name 1</name><description>Description 1 - current_admin</description></profile>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class OverridingSerializationScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_xml_overriding_serialization_scope
          render xml: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
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

      def test_render_xml_overriding_serialization_scope
        get :render_xml_overriding_serialization_scope
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profile><name>Name 1</name><description>Description 1 - current_admin</description></profile>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class CallingSerializationScopeTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_xml_calling_serialization_scope
          render xml: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        private

        def current_user
          'current_user'
        end

        serialization_scope :current_user
      end

      tests MyController

      def test_render_xml_calling_serialization_scope
        get :render_xml_calling_serialization_scope
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profile><name>Name 1</name><description>Description 1 - current_user</description></profile>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class RailsSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_xml_using_rails_behavior
          render xml: [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })], serializer: false
        end
      end

      tests MyController

      def test_render_xml_using_rails_behavior
        get :render_xml_using_rails_behavior
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<profiles type="array"><profile type="Profile">.+</profile></profiles>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

    class ArraySerializerTest < ActionController::TestCase
      class MyController < ActionController::Base

        def render_xml_array
          render xml: [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })]
        end
      end

      tests MyController

      def test_render_xml_array
        get :render_xml_array
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml('<my type="array"><my><name>Name 1</name><description>Description 1</description></my></my>'), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
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

        def render_xml_array_embeding_in_root
          render xml: [@user]
        end
      end

      tests MyController

      def test_render_xml_array_embeding_in_root
        @association.embed = :ids
        @association.embed_in_root = true

        get :render_xml_array_embeding_in_root
        assert_equal 'application/xml', @response.content_type
        assert_match format_xml("<result><my type=\"array\"><my><name>Name 1</name><email>mail@server.com</email><profile-id type=\"integer\">#{@controller.user.profile.object_id}</profile-id></my></my><profiles type=\"array\"><profile><name>N1</name><description>D1</description></profile></profiles></result>"), @response.body
      end

      def format_xml(str)
        str.gsub!('><', '>\s*<')
        %r{<\?xml[^>]+\?>\s+#{str}}
      end
    end

  end
end

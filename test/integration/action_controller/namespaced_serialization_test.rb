require 'test_helper'

module ActionController
  module Serialization
    class NamespacedSerializationTest < ActionController::TestCase
      class TestNamespace::MyController < ActionController::Base
        def render_profile_with_namespace
          render json: Profile.new({ name: 'Name 1', description: 'Description 1'})
        end

        def render_profiles_with_namespace
          render json: [Profile.new({ name: 'Name 1', description: 'Description 1'})]
        end

        def render_comment
          render json: Comment.new(content: 'Comment 1')
        end

        def render_comments
          render json: [Comment.new(content: 'Comment 1')]
        end

        def render_hash
          render json: {message: 'not found'}, status: 404
        end
      end

      tests TestNamespace::MyController

      def test_render_profile_with_namespace
        get :render_profile_with_namespace
        assert_serializer TestNamespace::ProfileSerializer
      end

      def test_render_profiles_with_namespace
        get :render_profiles_with_namespace
        assert_serializer TestNamespace::ProfileSerializer
      end

      def test_fallback_to_a_version_without_namespace
        get :render_comment
        assert_serializer CommentSerializer
      end

      def test_array_fallback_to_a_version_without_namespace
        get :render_comments
        assert_serializer CommentSerializer
      end

      def test_render_hash_regression
        get :render_hash
        assert_equal JSON.parse(response.body), {'message' => 'not found'}
      end
    end

    class OptionNamespacedSerializationTest < ActionController::TestCase
      class MyController < ActionController::Base
        def default_serializer_options
          {
            namespace: TestNamespace
          }
        end

        def render_profile_with_namespace_option
          render json: Profile.new({ name: 'Name 1', description: 'Description 1'})
        end

        def render_profiles_with_namespace_option
          render json: [Profile.new({ name: 'Name 1', description: 'Description 1'})]
        end

        def render_comment
          render json: Comment.new(content: 'Comment 1')
        end

        def render_comments
          render json: [Comment.new(content: 'Comment 1')]
        end
      end

      tests MyController

      def test_render_profile_with_namespace_option
        get :render_profile_with_namespace_option
        assert_serializer TestNamespace::ProfileSerializer
      end

      def test_render_profiles_with_namespace_option
        get :render_profiles_with_namespace_option
        assert_serializer TestNamespace::ProfileSerializer
      end

      def test_fallback_to_a_version_without_namespace
        get :render_comment
        assert_serializer CommentSerializer
      end

      def test_array_fallback_to_a_version_without_namespace
        get :render_comments
        assert_serializer CommentSerializer
      end
    end

  end
end

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

        def render_array_using_implicit_serializer_and_meta
          old_adapter = ActiveModel::Serializer.config.adapter

          ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
          array = [
            Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          ]
          render json: array, meta: { total: 10 }
          ensure
          ActiveModel::Serializer.config.adapter = old_adapter
        end

        def render_object_with_cache_enabled
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new({ id: 1, title: 'New Post', blog:nil, body: 'Body', comments: [comment], author: author })

          generate_cached_serializer(post)

          post.title = 'ZOMG a New Post'
          render json: post
        end

        def render_object_expired_with_cache_enabled
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new({ id: 1, title: 'New Post', blog:nil, body: 'Body', comments: [comment], author: author })

          generate_cached_serializer(post)

          post.title = 'ZOMG a New Post'
          sleep 0.05
          render json: post
        end

        def render_changed_object_with_cache_enabled
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new({ id: 1, title: 'ZOMG a New Post', blog:nil, body: 'Body', comments: [comment], author: author })

          render json: post
        end

        private
        def generate_cached_serializer(obj)
          serializer_class = ActiveModel::Serializer.serializer_for(obj)
          serializer = serializer_class.new(obj)
          adapter = ActiveModel::Serializer.adapter.new(serializer)
          adapter.to_json
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
        assert_equal '{"data":{"name":"Name 1","description":"Description 1"}}', @response.body
      end

      def test_render_using_custom_root_in_adapter_with_a_default
        get :render_using_custom_root_in_adapter_with_a_default

        assert_equal 'application/json', @response.content_type
        assert_equal '{"data":{"name":"Name 1","description":"Description 1"}}', @response.body
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

      def test_render_array_using_implicit_serializer_and_meta
        get :render_array_using_implicit_serializer_and_meta

        assert_equal 'application/json', @response.content_type
        assert_equal '{"data":[{"name":"Name 1","description":"Description 1"}],"meta":{"total":10}}', @response.body
      end

      def test_render_with_cache_enable
        ActionController::Base.cache_store.clear
        get :render_object_with_cache_enabled

        expected = {
          id: 1,
          title: 'New Post',
          body: 'Body',
          comments: [
            {
              id: 1,
              body: 'ZOMG A COMMENT' }
          ],
          blog: {
            id: 999,
            name: 'Custom blog'
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body

        get :render_changed_object_with_cache_enabled
        assert_equal expected.to_json, @response.body

        ActionController::Base.cache_store.clear
        get :render_changed_object_with_cache_enabled
        assert_not_equal expected.to_json, @response.body
      end

      def test_render_with_cache_enable_and_expired
        ActionController::Base.cache_store.clear
        get :render_object_expired_with_cache_enabled

        expected = {
          id: 1,
          title: 'ZOMG a New Post',
          body: 'Body',
          comments: [
            {
              id: 1,
              body: 'ZOMG A COMMENT' }
          ],
          blog: {
            id: 999,
            name: 'Custom blog'
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end
    end
  end
end

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
          with_adapter ActiveModel::Serializer::Adapter::JsonApi do
            # JSON-API adapter sets root by default
            @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
            render json: @profile
          end
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
          with_adapter ActiveModel::Serializer::Adapter::JsonApi do

            @profiles = [
              Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
            ]

            render json: @profiles, meta: { total: 10 }
          end
        end

        def render_object_with_cache_enabled
          @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          @author  = Author.new(id: 1, name: 'Joao Moura.')
          @post    = Post.new({ id: 1, title: 'New Post', body: 'Body', comments: [@comment], author: @author })

          generate_cached_serializer(@post)

          @post.title = 'ZOMG a New Post'
          render json: @post
        end

        def update_and_render_object_with_cache_enabled
          @post.updated_at = DateTime.now

          generate_cached_serializer(@post)
          render json: @post
        end

        def render_object_expired_with_cache_enabled
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new({ id: 1, title: 'New Post', body: 'Body', comments: [comment], author: author })

          generate_cached_serializer(post)

          post.title = 'ZOMG a New Post'
          sleep 0.1
          render json: post
        end

        def render_changed_object_with_cache_enabled
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new({ id: 1, title: 'ZOMG a New Post', body: 'Body', comments: [comment], author: author })

          render json: post
        end

        def render_fragment_changed_object_with_only_cache_enabled
          author = Author.new(id: 1, name: 'Joao Moura.')
          role = Role.new({ id: 42, name: 'ZOMG A ROLE', description: 'DESCRIPTION HERE', author: author })

          generate_cached_serializer(role)
          role.name = 'lol'
          role.description = 'HUEHUEBRBR'

          render json: role
        end

        def render_fragment_changed_object_with_except_cache_enabled
          author = Author.new(id: 1, name: 'Joao Moura.')
          bio = Bio.new({ id: 42, content: 'ZOMG A ROLE', rating: 5, author: author })

          generate_cached_serializer(bio)
          bio.content = 'lol'
          bio.rating = 0

          render json: bio
        end

        def render_fragment_changed_object_with_relationship
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new({ id: 1, title: 'New Post', body: 'Body', comments: [comment], author: author })
          post2 = Post.new({ id: 1, title: 'New Post2', body: 'Body2', comments: [comment], author: author })
          like = Like.new({ id: 1, post: post, time: 3.days.ago })

          generate_cached_serializer(like)
          like.post = post2
          like.time = DateTime.now.to_s

          render json: like
        end

        private
        def generate_cached_serializer(obj)
          serializer_class = ActiveModel::Serializer.serializer_for(obj)
          serializer = serializer_class.new(obj)
          adapter = ActiveModel::Serializer.adapter.new(serializer)
          adapter.to_json
        end

        def with_adapter(adapter)
          old_adapter = ActiveModel::Serializer.config.adapter
          # JSON-API adapter sets root by default
          ActiveModel::Serializer.config.adapter = adapter
          yield
        ensure
          ActiveModel::Serializer.config.adapter = old_adapter
        end
      end

      tests MyController

      # We just have Null for now, this will change
      def test_render_using_implicit_serializer
        get :render_using_implicit_serializer

        expected = {
          name: "Name 1",
          description: "Description 1"
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_using_custom_root
        get :render_using_custom_root

        assert_equal 'application/json', @response.content_type
        assert_equal '{"custom_root":{"name":"Name 1","description":"Description 1"}}', @response.body
      end

      def test_render_using_default_root
        get :render_using_default_adapter_root

        expected = {
          data: {
            id: assigns(:profile).id.to_s,
            type: "profiles",
            attributes: {
              name: "Name 1",
              description: "Description 1"
            }
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_using_custom_root_in_adapter_with_a_default
        get :render_using_custom_root_in_adapter_with_a_default

        expected = {
          data: {
            id: assigns(:profile).id.to_s,
            type: "profiles",
            attributes: {
              name: "Name 1",
              description: "Description 1"
            }
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
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

        expected = {
          data: [
            {
              id: assigns(:profiles).first.id.to_s,
              type: "profiles",
              attributes: {
                name: "Name 1",
                description: "Description 1"
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

      def test_render_with_fragment_only_cache_enable
        ActionController::Base.cache_store.clear
        get :render_fragment_changed_object_with_only_cache_enabled
        response = JSON.parse(@response.body)

        assert_equal 'application/json', @response.content_type
        assert_equal 'ZOMG A ROLE', response["name"]
        assert_equal 'HUEHUEBRBR', response["description"]
      end

      def test_render_with_fragment_except_cache_enable
        ActionController::Base.cache_store.clear
        get :render_fragment_changed_object_with_except_cache_enabled
        response = JSON.parse(@response.body)

        assert_equal 'application/json', @response.content_type
        assert_equal 5, response["rating"]
        assert_equal 'lol', response["content"]
      end

      def test_render_fragment_changed_object_with_relationship
        ActionController::Base.cache_store.clear
        get :render_fragment_changed_object_with_relationship
        response = JSON.parse(@response.body)

        expected_return = {
          "id"=>1,
          "time"=>DateTime.now.to_s,
          "post" => {
            "id"=>1,
            "title"=>"New Post",
            "body"=>"Body"
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected_return, response
      end

      def test_cache_expiration_on_update
        ActionController::Base.cache_store.clear
        get :render_object_with_cache_enabled

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
            id:999,
            name: "Custom blog"
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        get :update_and_render_object_with_cache_enabled

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end
    end
  end
end

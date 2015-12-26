require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ResourceTypeConfigTest < Minitest::Test
          class ProfileTypeSerializer < ActiveModel::Serializer
            attributes :name
            type 'profile'
          end

          class SpecialProfileTypeSerializer < ProfileTypeSerializer
            type 'special_profile'
          end

          class PostTypeSerializer < ActiveModel::Serializer
            type { object.type }
          end

          class SpecialPostTypeSerializer < PostTypeSerializer
            type { 'special_post' }
          end

          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @author.bio = nil
            @author.roles = []
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body', type: 'block_post')
            @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @post.blog = @blog
            @anonymous_post.comments = []
            @anonymous_post.blog = nil
            @comment.post = @post
            @comment.author = nil
            @post.author = @author
            @anonymous_post.author = nil
            @blog = Blog.new(id: 1, name: 'My Blog!!')
            @blog.writer = @author
            @blog.articles = [@post, @anonymous_post]
            @author.posts = []
          end

          def test_config_plural
            with_jsonapi_resource_type :plural do
              assert_type('comments', @comment)
            end
          end

          def test_config_singular
            with_jsonapi_resource_type :singular do
              assert_type('comment', @comment)
            end
          end

          def test_explicit_type_value
            assert_type('profile', @author, serializer: ProfileTypeSerializer)
          end

          def test_explicit_type_value_for_subclass
            assert_type('special_profile', @author, serializer: SpecialProfileTypeSerializer)
          end

          def test_explicit_type_block
            assert_type('block_post', @post, serializer: PostTypeSerializer)
          end

          def test_explicit_type_block_for_subclass
            assert_type('special_post', @post, serializer: SpecialPostTypeSerializer)
          end

          private

          def with_jsonapi_resource_type type
            old_type = ActiveModelSerializers.config.jsonapi_resource_type
            ActiveModelSerializers.config.jsonapi_resource_type = type
            yield
          ensure
            ActiveModelSerializers.config.jsonapi_resource_type = old_type
          end

          def assert_type(type, object, options = {})
            options.merge!(adapter: :json_api)
            hash = serializable(object, options).serializable_hash
            assert_equal(type, hash.fetch(:data).fetch(:type))
          end

          def serializable(resource, options = {})
            ActiveModel::SerializableResource.new(resource, options)
          end
        end
      end
    end
  end
end

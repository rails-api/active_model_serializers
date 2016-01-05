require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ResourceTypeConfigTest < ActiveSupport::TestCase
          class ProfileTypeSerializer < ActiveModel::Serializer
            attributes :name
            type 'profile'
          end

          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @author.bio = nil
            @author.roles = []
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
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

          def with_jsonapi_resource_type type
            old_type = ActiveModelSerializers.config.jsonapi_resource_type
            ActiveModelSerializers.config.jsonapi_resource_type = type
            yield
          ensure
            ActiveModelSerializers.config.jsonapi_resource_type = old_type
          end

          def test_config_plural
            with_jsonapi_resource_type :plural do
              hash = serializable(@comment, adapter: :json_api).serializable_hash
              assert_equal('comments', hash[:data][:type])
            end
          end

          def test_config_singular
            with_jsonapi_resource_type :singular do
              hash = serializable(@comment, adapter: :json_api).serializable_hash
              assert_equal('comment', hash[:data][:type])
            end
          end

          def test_explicit_type_value
            hash = serializable(@author, serializer: ProfileTypeSerializer, adapter: :json_api).serializable_hash
            assert_equal('profile', hash.fetch(:data).fetch(:type))
          end

          private

          def serializable(resource, options = {})
            ActiveModel::SerializableResource.new(resource, options)
          end
        end
      end
    end
  end
end

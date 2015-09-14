require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class TopLevelJsonApiTest < Minitest::Test
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

          def with_config(option, value)
            old_value = ActiveModel::Serializer.config[option]
            ActiveModel::Serializer.config[option] = value
            yield
          ensure
            ActiveModel::Serializer.config[option] = old_value
          end

          def test_disable_toplevel_jsonapi
            with_adapter :json_api do
              with_config(:jsonapi_toplevel_member, false) do
                hash = ActiveModel::SerializableResource.new(@post).serializable_hash
                assert_nil(hash[:jsonapi])
              end
            end
          end

          def test_enable_toplevel_jsonapi
            with_adapter :json_api do
              with_config(:jsonapi_toplevel_member, true) do
                hash = ActiveModel::SerializableResource.new(@post).serializable_hash
                refute_nil(hash[:jsonapi])
              end
            end
          end

          def test_default_toplevel_jsonapi_version
            with_adapter :json_api do
              with_config(:jsonapi_toplevel_member, true) do
                hash = ActiveModel::SerializableResource.new(@post).serializable_hash
                assert_equal('1.0', hash[:jsonapi][:version])
              end
            end
          end

          def test_toplevel_jsonapi_no_meta
            with_adapter :json_api do
              with_config(:jsonapi_toplevel_member, true) do
                hash = ActiveModel::SerializableResource.new(@post).serializable_hash
                assert_nil(hash[:jsonapi][:meta])
              end
            end
          end

          def test_toplevel_jsonapi_meta
            with_adapter :json_api do
              with_config(:jsonapi_toplevel_member, true) do
                hash = ActiveModel::SerializableResource.new(@post, jsonapi_toplevel_meta: 'custom').serializable_hash
                assert_equal('custom', hash[:jsonapi][:meta])
              end
            end
          end
        end
      end
    end
  end
end

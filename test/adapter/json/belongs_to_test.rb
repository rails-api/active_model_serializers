require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class Json
        class BelongsToTest < Minitest::Test
          def setup
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @anonymous_post.comments = []
            @comment.post = @post
            @comment.author = nil
            @anonymous_post.author = nil
            @blog = Blog.new(id: 1, name: 'My Blog!!')
            @post.blog = @blog
            @anonymous_post.blog = nil

            ActionController::Base.cache_store.clear
          end

          def test_includes_post
            resource = SerializableResource.new(@comment, adapter: :json, serializer: CommentSerializer)
            expected = { id: 42, title: 'New Post', body: 'Body' }
            actual = resource.serializable_hash[:comment][:post]

            assert_equal(expected, actual)
          end

          def test_include_nil_author
            resource = SerializableResource.new(@anonymous_post, adapter: :json, serializer: PostSerializer)
            expected = {
              post: {
                title: 'Hello!!', body: 'Hello, world!!', id: 43,
                comments: [],
                blog: { id: 999, name: 'Custom blog' }, author: nil
              }
            }
            actual = resource.serializable_hash

            assert_equal(expected, actual)
          end

          def test_include_nil_author_with_specified_serializer
            resource = SerializableResource.new(@anonymous_post, adapter: :json, serializer: PostPreviewSerializer)
            expected = { post: { title: 'Hello!!', body: 'Hello, world!!', id: 43, comments: [], author: nil } }
            actual = resource.serializable_hash

            assert_equal(expected, actual)
          end
        end
      end
    end
  end
end

require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
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

            @serializer = CommentSerialization.new(@comment)
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_includes_post
            assert_equal({ id: 42, title: 'New Post', body: 'Body' }, @adapter.serializable_hash[:comment][:post])
          end

          def test_include_nil_author
            serializer = PostSerialization.new(@anonymous_post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            assert_equal({ post: { title: 'Hello!!', body: 'Hello, world!!', id: 43, comments: [], blog: { id: 999, name: 'Custom blog' }, author: nil } }, adapter.serializable_hash)
          end

          def test_include_nil_author_with_specified_serializer
            serializer = PostPreviewSerialization.new(@anonymous_post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            assert_equal({ post: { title: 'Hello!!', body: 'Hello, world!!', id: 43, comments: [], author: nil } }, adapter.serializable_hash)
          end
        end
      end
    end
  end
end

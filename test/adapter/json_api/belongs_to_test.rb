require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class BelongsToTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @anonymous_post.comments = []
            @comment.post = @post
            @post.author = @author
            @anonymous_post.author = nil

            @serializer = CommentSerializer.new(@comment)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
          end

          def test_includes_post_id
            assert_equal("42", @adapter.serializable_hash[:comments][:links][:post])
          end

          def test_includes_linked_post
            assert_equal([{id: "42", title: 'New Post', body: 'Body'}], @adapter.serializable_hash[:linked][:posts])
          end

          def test_include_nil_author
            serializer = PostSerializer.new(@anonymous_post)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)

            assert_equal({comments: [], author: nil}, adapter.serializable_hash[:posts][:links])
          end
        end
      end
    end
  end
end

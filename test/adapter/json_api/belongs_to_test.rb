require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApiAdapter
        class BelongsToTest < Minitest::Test
          def setup
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @comment.post = @post

            @serializer = CommentSerializer.new(@comment)
            @adapter = ActiveModel::Serializer::Adapter::JsonApiAdapter.new(@serializer)
          end

          def test_includes_post_id
            assert_equal(42, @adapter.serializable_hash[:links][:post])
          end

          def test_includes_linked_post
            assert_equal([{id: 42, title: 'New Post', body: 'Body'}], @adapter.serializable_hash[:linked][:posts])
          end
        end
      end
    end
  end
end

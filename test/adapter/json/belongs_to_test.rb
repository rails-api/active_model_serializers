require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class Json
        class BelongsToTest < Minitest::Test
          def setup
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @comment.post = @post

            @serializer = CommentSerializer.new(@comment)
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)
          end

          def test_includes_post
            assert_equal({id: 42, title: 'New Post', body: 'Body'}, @adapter.serializable_hash[:post])
          end
        end
      end
    end
  end
end

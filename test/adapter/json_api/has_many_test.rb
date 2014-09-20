require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class HasManyTest < Minitest::Test
          def setup
            @post = Post.new(title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @post.comments = [@first_comment, @second_comment]
            @first_comment.post = @post
            @second_comment.post = @post

            @serializer = PostSerializer.new(@post)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
          end

          def test_includes_comment_ids
            assert_equal([1, 2], @adapter.serializable_hash[:links][:comments])
          end

          def test_includes_linked_comments
            assert_equal([
                           {id: 1, body: 'ZOMG A COMMENT'},
                           {id: 2, body: 'ZOMG ANOTHER COMMENT'}
                         ], @adapter.serializable_hash[:linked][:comments])
          end
        end
      end
    end
  end
end

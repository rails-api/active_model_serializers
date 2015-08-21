require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class NestedJsonTest < Minitest::Test
        def setup
          ActionController::Base.cache_store.clear
          @author = Author.new(id: 1, name: 'Steve K.')
          @post = Post.new(id: 1, title: 'New Post', body: 'Body')
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @post.comments = [@first_comment, @second_comment]
          @author.posts = [@post]

          @serializer = AuthorNestedSerializer.new(@author)
          @adapter = ActiveModel::Serializer::Adapter::NestedJson.new(@serializer)
        end

        def test_has_many
          assert_equal({
            id: 1, name: 'Steve K.',
            posts: [{
              id: 1, title: 'New Post', body: 'Body',
              comments: [
                {id: 1, body: 'ZOMG A COMMENT'},
                {id: 2, body: 'ZOMG ANOTHER COMMENT'}
              ]
            }]
          }, @adapter.serializable_hash)
        end

        def test_limit_depth
          assert_raises do
            @adapter.serializable_hash(limit_depth: 1)
          end
        end
      end
    end
  end
end

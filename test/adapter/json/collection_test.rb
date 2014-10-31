require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class Json
        class Collection < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
            @first_post.comments = []
            @second_post.comments = []
            @first_post.author = @author
            @second_post.author = @author

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)
          end

          def test_include_multiple_posts
            assert_equal([
                           {title: "Hello!!", body: "Hello, world!!", id: 1, comments: [], author: {id: 1, name: "Steve K."}},
                           {title: "New Post", body: "Body", id: 2, comments: [], author: {id: 1, name: "Steve K."}}
                         ], @adapter.serializable_hash)
          end
        end
      end
    end
  end
end

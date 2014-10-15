require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class Collection < Minitest::Test
          def setup
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
            @first_post.comments = []
            @second_post.comments = []

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
          end

          def test_include_multiple_posts
            assert_equal([
                           {title: "Hello!!", body: "Hello, world!!", id: "1", links: {comments: []}},
                           {title: "New Post", body: "Body", id: "2", links: {comments: []}}
                         ], @adapter.serializable_hash[:posts])
          end
        end
      end
    end
  end
end

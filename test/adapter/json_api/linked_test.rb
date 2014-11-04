require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class LinkedTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
            @first_post.comments = []
            @second_post.comments = []
            @first_post.author = @author
            @second_post.author = @author
            @author.posts = [@first_post, @second_post]

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, include: 'author,comments')
          end

          def test_include_multiple_posts_and_linked
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @first_post.comments = [@first_comment, @second_comment]
            @first_comment.post = @first_post
            @first_comment.author = nil
            @second_comment.post = @first_post
            @second_comment.author = nil
            assert_equal([
                           { title: "Hello!!", body: "Hello, world!!", id: "1", links: { comments: ['1', '2'], author: "1" } },
                           { title: "New Post", body: "Body", id: "2", links: { comments: [], :author => "1" } }
                         ], @adapter.serializable_hash[:posts])
            assert_equal({ :comments => [{ :id => "1", :body => "ZOMG A COMMENT" }, { :id => "2", :body => "ZOMG ANOTHER COMMENT" }], :authors => [{ :id => "1", :name => "Steve K." }] }, @adapter.serializable_hash[:linked])
          end
        end
      end
    end
  end
end

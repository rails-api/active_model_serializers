require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class LinkedTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @bio = Bio.new(id: 1, content: 'AMS Contributor')
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
            @first_post.comments = []
            @second_post.comments = []
            @first_post.author = @author
            @second_post.author = @author
            @author.posts = [@first_post, @second_post]
            @author.bio = @bio
            @author.roles = []
            @bio.author = @author

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, include: 'author,author.bio,comments')
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


            expected = {
              comments: [{
                id: "1",
                body: "ZOMG A COMMENT",
                links: {
                  post: "1",
                  author: nil
                }
              }, {
                id: "2",
                body: "ZOMG ANOTHER COMMENT",
                links: {
                  post: "1",
                  author: nil
                }
              }],
              authors: [{
                id: "1",
                name: "Steve K.",
                links: {
                  posts: ["1", "2"],
                  roles: [],
                  bio: "1"
                }
              }],
              bios: [{
                id: "1",
                content: "AMS Contributor",
                links: {
                  author: "1"
                }
              }]
            }
            assert_equal expected, @adapter.serializable_hash[:linked]
          end
        end
      end
    end
  end
end

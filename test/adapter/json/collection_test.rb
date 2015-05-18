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
            @blog = Blog.new(id: 1, name: "My Blog!!")
            @first_post.blog = @blog
            @second_post.blog = nil

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_with_serializer_option
            @blog.special_attribute = "Special"
            @blog.articles = [@first_post, @second_post]
            @serializer = ArraySerializer.new([@blog], serializer: CustomBlogSerializer)
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)

            expected = [{
              id: 1,
              special_attribute: "Special",
              articles: [{id: 1,title: "Hello!!", body: "Hello, world!!"}, {id: 2, title: "New Post", body: "Body"}]
            }]
            assert_equal expected, @adapter.serializable_hash
          end

          def test_include_multiple_posts
            expected = [{
              title: "Hello!!",
              body: "Hello, world!!",
              id: 1,
              comments: [],
              author: {
                id: 1,
                name: "Steve K."
              },
              blog: {
                id: 999,
                name: "Custom blog"
              }
            }, {
              title: "New Post",
              body: "Body",
              id: 2,
              comments: [],
              author: {
                id: 1,
                name: "Steve K."
              },
              blog: {
                id: 999,
                name: "Custom blog"
              }
            }]
            assert_equal expected, @adapter.serializable_hash
          end
        end
      end
    end
  end
end

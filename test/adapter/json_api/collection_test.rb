require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class CollectionTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @author.bio = nil
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
            @first_post.comments = []
            @second_post.comments = []
            @first_post.blog = @blog
            @second_post.blog = nil
            @first_post.author = @author
            @second_post.author = @author
            @author.posts = [@first_post, @second_post]

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_include_multiple_posts
            assert_equal([
                           { title: "Hello!!", body: "Hello, world!!", id: "1", links: { comments: [], blog: "999", author: "1" } },
                           { title: "New Post", body: "Body", id: "2", links: { comments: [], blog: nil, author: "1" } }
                         ], @adapter.serializable_hash[:posts])
          end

          def test_limiting_fields
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, fields: ['title', 'comments'])
            assert_equal([
              { title: "Hello!!", links: { comments: [] } },
              { title: "New Post", links: { comments: [] } }
            ], @adapter.serializable_hash[:posts])
          end

        end
      end
    end
  end
end

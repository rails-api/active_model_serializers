require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class HasManyEmbedIdsTest < ActiveSupport::TestCase
        def setup
          @author = Author.new(name: 'Steve K.')
          @author.bio = nil
          @author.roles = nil
          @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
          @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
          @author.posts = [@first_post, @second_post]
          @first_post.author = @author
          @second_post.author = @author
          @first_post.comments = []
          @second_post.comments = []
          @blog = Blog.new(id: 23, name: 'AMS Blog')
          @first_post.blog = @blog
          @second_post.blog = nil

          @serializer = AuthorSerializer.new(@author)
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer)
        end

        def test_includes_comment_ids
          expected = {
            data: [
              { type: 'posts', id: '1' },
              { type: 'posts', id: '2' }
            ]
          }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:posts])
        end

        def test_no_includes_linked_comments
          assert_nil @adapter.serializable_hash[:linked]
        end
      end
    end
  end
end

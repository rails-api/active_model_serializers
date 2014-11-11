require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class HasManyEmbedIdsTest < Minitest::Test
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

            @serializer = AuthorSerializer.new(@author)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
          end

          def test_includes_comment_ids
            assert_equal(["1", "2"], @adapter.serializable_hash[:authors][:links][:posts])
          end

          def test_no_includes_linked_comments
            assert_nil @adapter.serializable_hash[:linked]
          end
        end
      end
    end
  end
end

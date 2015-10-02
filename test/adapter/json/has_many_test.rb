require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class Json
        class HasManyTestTest < Minitest::Test
          def setup
            ActionController::Base.cache_store.clear
            @author = Author.new(id: 1, name: 'Steve K.')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @post.comments = [@first_comment, @second_comment]
            @post.author = @author
            @first_comment.post = @post
            @second_comment.post = @post
            @blog = Blog.new(id: 1, name: 'My Blog!!')
            @post.blog = @blog
            @tag = Tag.new(id: 1, name: '#hash_tag')
            @post.tags = [@tag]
          end

          def test_has_many
            resource = SerializableResource.new(
              @post,
              adapter: :json,
              serializer: PostSerializer
            )

            expected = [
              { id: 1, body: 'ZOMG A COMMENT' },
              { id: 2, body: 'ZOMG ANOTHER COMMENT' }
            ]
            actual = resource.serializable_hash[:post][:comments]

            assert_equal expected, actual
          end

          def test_has_many_with_no_serializer
            resource = SerializableResource.new(
              @post,
              adapter: :json,
              serializer: PostWithTagsSerializer
            )

            expected = {
              id: 42,
              tags: [
                { 'attributes' => { 'id' => 1, 'name' => '#hash_tag' } }
              ]
            }.to_json
            actual = resource.serializable_hash[:post].to_json

            assert_equal expected, actual
          end
        end
      end
    end
  end
end

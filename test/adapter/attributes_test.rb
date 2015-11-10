require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class AttributesTest < Minitest::Test
        class PostTestSerializer < Serializer
          attributes :id, :title

          has_many :comments, include: :author
          belongs_to :author
        end

        def setup
          Rails.cache.clear
          @first_author = Author.new(id: 1, name: 'Marge S.')
          @second_author = Author.new(id: 2, name: 'Homer S.')
          @post = Post.new(id: 1, title: 'New Post')
          @comment = Comment.new(id: 1, body: 'A COMMENT')

          @post.comments = [@comment]
          @comment.post = @post
          @comment.author = @second_author
          @post.author = @first_author

          @serializer = PostTestSerializer.new(@post)
        end

        def test_association_include
          @adapter = ActiveModel::Serializer::Adapter::Attributes.new(@serializer)

          assert_equal({
            id: 1,
            title: 'New Post',
            comments: [{
              id: 1,
              body: 'A COMMENT',
              author: { id: 2, name: 'Homer S.' }
            }],
            author: { id: 1, name: 'Marge S.' }
            }, @adapter.serializable_hash)
        end

        def test_overwriting_association_include
          @adapter = ActiveModel::Serializer::Adapter::Attributes.
            new(@serializer, include: :author)

          assert_equal({
            id: 1,
            title: 'New Post',
            author: { id: 1, name: 'Marge S.' }
            }, @adapter.serializable_hash)
        end
      end
    end
  end
end

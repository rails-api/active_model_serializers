require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        # Test 'has_many :assocs, serializer: AssocXSerializer'
        class HasManyExplicitSerializerTest < Minitest::Test
          def setup
            @post = Post.new(title: 'New Post', body: 'Body')
            @author = Author.new(name: 'Jane Blogger')
            @author.posts = [@post]
            @post.author = @author
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @post.comments = [@first_comment, @second_comment]
            @first_comment.post = @post
            @first_comment.author = nil
            @second_comment.post = @post
            @second_comment.author = nil

            @serializer = PostPreviewSerializer.new(@post)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              @serializer,
              include: 'comments,author'
            )
          end

          def test_includes_comment_ids
            assert_equal(['1', '2'],
                         @adapter.serializable_hash[:posts][:links][:comments])
          end

          def test_includes_linked_comments
            assert_equal([{ id: '1', body: "ZOMG A COMMENT", links: { post: @post.id.to_s, author: nil }},
                          { id: '2', body: "ZOMG ANOTHER COMMENT", links: { post: @post.id.to_s, author: nil }}],
                         @adapter.serializable_hash[:linked][:comments])
          end

          def test_includes_author_id
            assert_equal(@author.id.to_s,
                         @adapter.serializable_hash[:posts][:links][:author])
          end

          def test_includes_linked_authors
            assert_equal([{ id: @author.id.to_s, links: { posts: [@post.id.to_s] } }],
                         @adapter.serializable_hash[:linked][:authors])
          end

          def test_explicit_serializer_with_null_resource
            @post.author = nil
            assert_equal(nil,
                         @adapter.serializable_hash[:posts][:links][:author])
          end

          def test_explicit_serializer_with_null_collection
            @post.comments = []
            assert_equal([],
                         @adapter.serializable_hash[:posts][:links][:comments])
          end
        end
      end
    end
  end
end

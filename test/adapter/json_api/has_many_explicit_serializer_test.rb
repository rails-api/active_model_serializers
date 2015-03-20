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
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @post.blog = @blog

            @serializer = PostPreviewSerializer.new(@post)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              @serializer,
              include: ['comments', 'author']
            )
          end

          def test_includes_comment_ids
            expected = {
              linkage: [
                { type: 'comments', id: '1' },
                { type: 'comments', id: '2' }
              ]
            }

            assert_equal(expected, @adapter.serializable_hash[:data][:links][:comments])
          end

          def test_includes_linked_comments
            # If CommentPreviewSerializer is applied correctly the body text will not be present in the output
            expected = [
              {
                id: '1',
                links: {
                  post: { linkage: { type: 'posts', id: @post.id.to_s } }
                }
              },
              {
                id: '2',
                links: {
                  post: { linkage: { type: 'posts', id: @post.id.to_s } }
                }
              }
            ]

            assert_equal(expected,
                         @adapter.serializable_hash[:linked][:comments])
          end

          def test_includes_author_id
            expected = {
              linkage: { type: "authors", id: @author.id.to_s }
            }

            assert_equal(expected, @adapter.serializable_hash[:data][:links][:author])
          end

          def test_includes_linked_authors
            expected = [{
              id: @author.id.to_s,
              links: {
                posts: { linkage: [ { type: "posts", id: @post.id.to_s } ] }
              }
            }]

            assert_equal(expected, @adapter.serializable_hash[:linked][:authors])
          end

          def test_explicit_serializer_with_null_resource
            @post.author = nil

            expected = { linkage: nil }

            assert_equal(expected, @adapter.serializable_hash[:data][:links][:author])
          end

          def test_explicit_serializer_with_null_collection
            @post.comments = []

            expected = { linkage: [] }

            assert_equal(expected, @adapter.serializable_hash[:data][:links][:comments])
          end
        end
      end
    end
  end
end

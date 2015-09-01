require 'test_helper'

NestedPostSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :title

  has_many :comments, include: :author
end

NestedCommentBelongsToSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :body

  belongs_to :author, include: [:posts]
end

NestedAuthorSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :name

  has_many :posts, include: [:comments]
end

ComplexNestedAuthorSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :name

  # it would normally be silly to have this in production code, cause a post's
  # author in this case is always going to be your root object
  has_many :posts, include: [:author, comments: [:author]]
end

module ActiveModel
  class Serializer
    class Adapter
      class Json
        class NestedRelationShipsTestTest < Minitest::Test
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

            @blog = Blog.new(id: 1, name: "My Blog!!")
            @post.blog = @blog
            @author.posts = [@post]
          end

          def test_complex_nested_has_many
            @first_comment.author = @author
            @second_comment.author = @author

            serializer = ComplexNestedAuthorSerializer.new(@author)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            expected = {
              author: {
                id: 1,
                name: 'Steve K.',
                posts: [
                  {
                    id: 42, title: 'New Post', body: 'Body',
                    author: {
                      id: 1,
                      name: 'Steve K.'
                    },
                    comments: [
                      {
                        id: 1, body: 'ZOMG A COMMENT',
                        author: {
                          id: 1,
                          name: 'Steve K.'
                        }
                      },
                      {
                        id: 2, body: 'ZOMG ANOTHER COMMENT',
                        author: {
                          id: 1,
                          name: 'Steve K.'
                        }
                      }
                    ]
                  }
                ]
              }
            }

            actual = adapter.serializable_hash

            assert_equal(expected, actual)
          end

          def test_nested_has_many
            serializer = NestedAuthorSerializer.new(@author)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            expected = {
              author: {
                id: 1,
                name: 'Steve K.',
                posts: [
                  {
                    id: 42, title: 'New Post', body: 'Body',
                    comments: [
                      {
                        id: 1, body: 'ZOMG A COMMENT'
                      },
                      {
                        id: 2, body: 'ZOMG ANOTHER COMMENT'
                      }
                    ]
                  }
                ]
              }
            }

            actual = adapter.serializable_hash

            assert_equal(expected, actual)
          end

          def test_belongs_to_on_a_has_many
            @first_comment.author = @author
            @second_comment.author = @author

            serializer = NestedPostSerializer.new(@post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            expected = {
              post: {
                id: 42, title: 'New Post',
                comments: [
                  {
                    id: 1, body: 'ZOMG A COMMENT',
                    author: {
                      id: 1,
                      name: 'Steve K.'
                    }
                  },
                  {
                    id: 2, body: 'ZOMG ANOTHER COMMENT',
                    author: {
                      id: 1,
                      name: 'Steve K.'
                    }
                  }
                ]
              },
            }

            actual = adapter.serializable_hash

            assert_equal(expected, actual)
          end

          def test_belongs_to_with_a_has_many
            @author.roles = []
            @author.bio = {}
            @first_comment.author = @author
            @second_comment.author = @author

            serializer = NestedCommentBelongsToSerializer.new(@first_comment)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            expected = {
              comment: {
                id: 1, body: 'ZOMG A COMMENT',
                author: {
                  id: 1,
                  name: 'Steve K.',
                  posts: [
                    {
                      id: 42, title: 'New Post', body: 'Body'
                    }
                  ]
                }
              }
            }

            actual = adapter.serializable_hash

            assert_equal(expected, actual)
          end

          def test_include_array_to_hash
            serializer = NestedCommentBelongsToSerializer.new(@first_comment)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            expected = {author: [], comments: {author: :bio}, posts: [:comments]}
            input = [:author, comments: {author: :bio}, posts: [:comments]]
            actual = adapter.send(:include_array_to_hash, input)

            assert_equal(expected, actual)
          end
        end
      end
    end
  end
end

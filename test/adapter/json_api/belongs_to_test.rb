require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class BelongsToTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @author.bio = nil
            @author.roles = []
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @post.blog = @blog
            @anonymous_post.comments = []
            @anonymous_post.blog = nil
            @comment.post = @post
            @comment.author = nil
            @post.author = @author
            @anonymous_post.author = nil
            @blog = Blog.new(id: 1, name: "My Blog!!")
            @blog.writer = @author
            @blog.articles = [@post, @anonymous_post]
            @author.posts = []

            @serializer = CommentSerializer.new(@comment)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_includes_post_id
            expected = { linkage: { type: "posts", id: "42" } }

            assert_equal(expected, @adapter.serializable_hash[:data][:links][:post])
          end

          def test_includes_linked_post
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, include: 'post')
            expected = [{
              id: "42",
              title: 'New Post',
              body: 'Body',
              links: {
                comments: { linkage: [ { type: "comments", id: "1" } ] },
                blog: { linkage: { type: "blogs", id: "999" } },
                author: { linkage: { type: "authors", id: "1" } }
              }
            }]
            assert_equal expected, @adapter.serializable_hash[:linked][:posts]
          end

          def test_limiting_linked_post_fields
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, include: 'post', fields: {post: [:title]})
            expected = [{
              title: 'New Post',
              links: {
                comments: { linkage: [ { type: "comments", id: "1" } ] },
                blog: { linkage: { type: "blogs", id: "999" } },
                author: { linkage: { type: "authors", id: "1" } }
              }
            }]
            assert_equal expected, @adapter.serializable_hash[:linked][:posts]
          end

          def test_include_nil_author
            serializer = PostSerializer.new(@anonymous_post)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)

            assert_equal({comments: { linkage: [] }, blog: { linkage: { type: "blogs", id: "999" } }, author: { linkage: nil }}, adapter.serializable_hash[:data][:links])
          end

          def test_include_type_for_association_when_different_than_name
            serializer = BlogSerializer.new(@blog)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
            links = adapter.serializable_hash[:data][:links]
            expected = {
              writer: {
                linkage: {
                  type: "authors",
                  id: "1"
                }
              },
              articles: {
                linkage: [
                  {
                    type: "posts",
                    id: "42"
                  },
                  {
                    type: "posts",
                    id: "43"
                  }
                ]
              }
            }
            assert_equal expected, links
          end

          def test_include_linked_resources_with_type_name
            serializer = BlogSerializer.new(@blog)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer, include: ['writer', 'articles'])
            linked = adapter.serializable_hash[:linked]
            expected = {
              authors: [{
                id: "1",
                name: "Steve K.",
                links: {
                  posts: { linkage: [] },
                  roles: { linkage: [] },
                  bio: { linkage: nil }
                }
              }],
              posts: [{
                title: "New Post",
                body: "Body",
                id: "42",
                links: {
                  comments: { linkage: [ { type: "comments", id: "1" } ] },
                  blog: { linkage: { type: "blogs", id: "999" } },
                  author: { linkage: { type: "authors", id: "1" } }
                }
              }, {
                title: "Hello!!",
                body: "Hello, world!!",
                id: "43",
                links: {
                  comments: { linkage: [] },
                  blog: { linkage: { type: "blogs", id: "999" } },
                  author: { linkage: nil }
                }
              }]
            }
            assert_equal expected, linked
          end
        end
      end
    end
  end
end

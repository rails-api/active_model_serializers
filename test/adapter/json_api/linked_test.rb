require 'test_helper'
module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class LinkedTest < Minitest::Test
          def setup
            ActionController::Base.cache_store.clear
            @author1 = Author.new(id: 1, name: 'Steve K.')
            @author2 = Author.new(id: 2, name: 'Tenderlove')
            @bio1 = Bio.new(id: 1, content: 'AMS Contributor')
            @bio2 = Bio.new(id: 2, content: 'Rails Contributor')
            @first_post = Post.new(id: 10, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 20, title: 'New Post', body: 'Body')
            @third_post = Post.new(id: 30, title: 'Yet Another Post', body: 'Body')
            @blog = Blog.new({ name: 'AMS Blog' })
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @first_post.blog = @blog
            @second_post.blog = @blog
            @third_post.blog = nil
            @first_post.comments = [@first_comment, @second_comment]
            @second_post.comments = []
            @third_post.comments = []
            @first_post.author = @author1
            @second_post.author = @author2
            @third_post.author = @author1
            @first_comment.post = @first_post
            @first_comment.author = nil
            @second_comment.post = @first_post
            @second_comment.author = nil
            @author1.posts = [@first_post, @third_post]
            @author1.bio = @bio1
            @author1.roles = []
            @author2.posts = [@second_post]
            @author2.bio = @bio2
            @author2.roles = []
            @bio1.author = @author1
            @bio2.author = @author2
          end

          def test_include_multiple_posts_and_linked_array
            serializer = ArraySerializer.new([@first_post, @second_post])
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              serializer,
              include: ['author', 'author.bio', 'comments']
            )
            alt_adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              serializer,
              include: 'author,author.bio,comments'
            )

            expected = {
              data: [
                {
                  id: "10",
                  type: "posts",
                  attributes: {
                    title: "Hello!!",
                    body: "Hello, world!!"
                  },
                  relationships: {
                    comments: { data: [ { type: "comments", id: '1' }, { type: "comments", id: '2' } ] },
                    blog: { data: { type: "blogs", id: "999" } },
                    author: { data: { type: "authors", id: "1" } }
                  }
                },
                {
                  id: "20",
                  type: "posts",
                  attributes: {
                    title: "New Post",
                    body: "Body"
                  },
                  relationships: {
                    comments: { data: [] },
                    blog: { data: { type: "blogs", id: "999" } },
                    author: { data: { type: "authors", id: "2" } }
                  }
                }
              ],
              included: [
                {
                  id: "1",
                  type: "comments",
                  attributes: {
                    body: "ZOMG A COMMENT"
                  },
                  relationships: {
                    post: { data: { type: "posts", id: "10" } },
                    author: { data: nil }
                  }
                }, {
                  id: "2",
                  type: "comments",
                  attributes: {
                    body: "ZOMG ANOTHER COMMENT",
                  },
                  relationships: {
                    post: { data: { type: "posts", id: "10" } },
                    author: { data: nil }
                  }
                }, {
                  id: "1",
                  type: "authors",
                  attributes: {
                    name: "Steve K."
                  },
                  relationships: {
                    posts: { data: [ { type: "posts", id: "10" }, { type: "posts", id: "30" } ] },
                    roles: { data: [] },
                    bio: { data: { type: "bios", id: "1" } }
                  }
                }, {
                  id: "1",
                  type: "bios",
                  attributes: {
                    content: "AMS Contributor",
                    rating: nil
                  },
                  relationships: {
                    author: { data: { type: "authors", id: "1" } }
                  }
                }, {
                  id: "2",
                  type: "authors",
                  attributes: {
                    name: "Tenderlove"
                  },
                  relationships: {
                    posts: { data: [ { type: "posts", id:"20" } ] },
                    roles: { data: [] },
                    bio: { data: { type: "bios", id: "2" } }
                  }
                }, {
                  id: "2",
                  type: "bios",
                  attributes: {
                    rating: nil,
                    content: "Rails Contributor",
                  },
                  relationships: {
                    author: { data: { type: "authors", id: "2" } }
                  }
                }
              ]
            }
            assert_equal expected, adapter.serializable_hash
            assert_equal expected, alt_adapter.serializable_hash
          end

          def test_include_multiple_posts_and_linked
            serializer = BioSerializer.new @bio1
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              serializer,
              include: ['author', 'author.posts']
            )
            alt_adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              serializer,
              include: 'author,author.posts'
            )

            expected = [
              {
                id: "1",
                type: "authors",
                attributes: {
                  name: "Steve K."
                },
                relationships: {
                  posts: { data: [ { type: "posts", id: "10"}, { type: "posts", id: "30" }] },
                  roles: { data: [] },
                  bio: { data: { type: "bios", id: "1" }}
                }
              }, {
                id: "10",
                type: "posts",
                attributes: {
                  title: "Hello!!",
                  body: "Hello, world!!"
                },
                relationships: {
                  comments: { data: [ { type: "comments", id: "1"}, { type: "comments", id: "2" }] },
                  blog: { data: { type: "blogs", id: "999" } },
                  author: { data: { type: "authors", id: "1" } }
                }
              }, {
                id: "30",
                type: "posts",
                attributes: {
                  title: "Yet Another Post",
                  body: "Body"
                },
                relationships: {
                  comments: { data: [] },
                  blog: { data: { type: "blogs", id: "999" } },
                  author: { data: { type: "authors", id: "1" } }
                }
              }
            ]

            assert_equal expected, adapter.serializable_hash[:included]
            assert_equal expected, alt_adapter.serializable_hash[:included]
          end

          def test_ignore_model_namespace_for_linked_resource_type
            spammy_post = Post.new(id: 123)
            spammy_post.related = [Spam::UnrelatedLink.new(id: 456)]
            serializer = SpammyPostSerializer.new(spammy_post)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
            relationships = adapter.serializable_hash[:data][:relationships]
            expected = {
              related: {
                data: [{
                  type: 'unrelated_links',
                  id: '456'
                }]
              }
            }
            assert_equal expected, relationships
          end

          def test_multiple_references_to_same_resource
            serializer = ArraySerializer.new([@first_comment, @second_comment])
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              serializer,
              include: ['post']
            )

            expected = [
              {
                id: "10",
                type: "posts",
                attributes: {
                  title: "Hello!!",
                  body: "Hello, world!!"
                },
                relationships: {
                  comments: {
                    data: [{type: "comments", id: "1"}, {type: "comments", id: "2"}]
                  },
                  blog: {
                    data: {type: "blogs", id: "999"}
                  },
                  author: {
                    data: {type: "authors", id: "1"}
                  }
                }
              }
            ]

            assert_equal expected, adapter.serializable_hash[:included]
          end

          def test_nil_link_with_specified_serializer
            @first_post.author = nil
            serializer = PostPreviewSerializer.new(@first_post)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(
              serializer,
              include: ['author']
            )

            expected = {
              data: {
                id: "10",
                type: "posts",
                attributes: {
                  title: "Hello!!",
                  body: "Hello, world!!"
                },
                relationships: {
                  comments: { data: [ { type: "comments", id: '1' }, { type: "comments", id: '2' } ] },
                  author: { data: nil }
                }
              }
            }
            assert_equal expected, adapter.serializable_hash
          end
        end
      end
    end
  end
end

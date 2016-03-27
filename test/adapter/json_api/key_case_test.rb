require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class KeyCaseTest < ActiveSupport::TestCase
        Post = Class.new(::Model)
        class PostSerializer < ActiveModel::Serializer
          type 'posts'
          attributes :title, :body, :publish_at
          belongs_to :author
          has_many :comments

          link(:self) { post_url(object.id) }
          link(:post_authors) { post_authors_url(object.id) }
          link(:subscriber_comments) { post_comments_url(object.id) }

          meta do
            {
              rating: 5,
              favorite_count: 10
            }
          end
        end

        Author = Class.new(::Model)
        class AuthorSerializer < ActiveModel::Serializer
          type 'authors'
          attributes :first_name, :last_name
        end

        Comment = Class.new(::Model)
        class CommentSerializer < ActiveModel::Serializer
          type 'comments'
          attributes :body
          belongs_to :author
        end

        def setup
          Rails.application.routes.draw do
            resources :posts do
              resources :authors
              resources :comments
            end
          end
          @publish_at = 1.day.from_now
          @author = Author.new(id: 1, first_name: 'Bob', last_name: 'Jones')
          @comment1 = Comment.new(id: 7, body: 'cool', author: @author)
          @comment2 = Comment.new(id: 12, body: 'awesome', author: @author)
          @post = Post.new(id: 1337, title: 'Title 1', body: 'Body 1',
                           author: @author, comments: [@comment1, @comment2],
                           publish_at: @publish_at)
          @comment1.post = @post
          @comment2.post = @post
          @error_resource = ModelWithErrors.new
          @error_resource.errors.add(:published_at, 'must be in the future')
          @error_resource.errors.add(:title, 'must be longer')
        end

        def test_success_document_key_transform_default
          result = serialize_resource(@post, options(nil, serializer: PostSerializer))
          expected_result = {
            data: {
              id: '1337',
              type: 'posts',
              attributes: {
                title: 'Title 1',
                body: 'Body 1',
                :"publish-at" => @publish_at
              },
              relationships: {
                author: {
                  data: { id: '1', type: 'authors' }
                },
                comments: {
                  data: [
                    { id: '7', type: 'comments' },
                    { id: '12', type: 'comments' }
                  ]
                }
              },
              links: {
                self: 'http://example.com/posts/1337',
                :"post-authors" => 'http://example.com/posts/1337/authors',
                :"subscriber-comments" => 'http://example.com/posts/1337/comments'
              },
              meta: { rating: 5, :"favorite-count" => 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_success_document_key_transform_global_config
          result = with_config(key_transform: :camel_lower) do
            serialize_resource(@post, options(nil, serializer: PostSerializer))
          end
          expected_result = {
            data: {
              id: '1337',
              type: 'posts',
              attributes: {
                title: 'Title 1',
                body: 'Body 1',
                publishAt: @publish_at
              },
              relationships: {
                author: {
                  data: { id: '1', type: 'authors' }
                },
                comments: {
                  data: [
                    { id: '7', type: 'comments' },
                    { id: '12', type: 'comments' }
                  ]
                }
              },
              links: {
                self: 'http://example.com/posts/1337',
                postAuthors: 'http://example.com/posts/1337/authors',
                subscriberComments: 'http://example.com/posts/1337/comments'
              },
              meta: { rating: 5, favoriteCount: 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_success_doc_key_transform_serialization_ctx_overrides_global
          result = with_config(key_transform: :camel_lower) do
            serialize_resource(@post, options(:camel, serializer: PostSerializer))
          end
          expected_result = {
            Data: {
              Id: '1337',
              Type: 'posts',
              Attributes: {
                Title: 'Title 1',
                Body: 'Body 1',
                PublishAt: @publish_at
              },
              Relationships: {
                Author: {
                  Data: { Id: '1', Type: 'authors' }
                },
                Comments: {
                  Data: [
                    { Id: '7', Type: 'comments' },
                    { Id: '12', Type: 'comments' }
                  ]
                }
              },
              Links: {
                Self: 'http://example.com/posts/1337',
                PostAuthors: 'http://example.com/posts/1337/authors',
                SubscriberComments: 'http://example.com/posts/1337/comments'
              },
              Meta: { Rating: 5, FavoriteCount: 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_success_document_key_transform_dashed
          result = serialize_resource(@post, options(:dashed, serializer: PostSerializer))
          expected_result = {
            data: {
              id: '1337',
              type: 'posts',
              attributes: {
                title: 'Title 1',
                body: 'Body 1',
                :"publish-at" => @publish_at
              },
              relationships: {
                author: {
                  data: { id: '1', type: 'authors' }
                },
                comments: {
                  data: [
                    { id: '7', type: 'comments' },
                    { id: '12', type: 'comments' }
                  ]
                }
              },
              links: {
                self: 'http://example.com/posts/1337',
                :"post-authors" => 'http://example.com/posts/1337/authors',
                :"subscriber-comments" => 'http://example.com/posts/1337/comments'
              },
              meta: { rating: 5, :"favorite-count" => 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_success_document_key_transform_unaltered
          result = serialize_resource(@post, options(:unaltered, serializer: PostSerializer))
          expected_result = {
            data: {
              id: '1337',
              type: 'posts',
              attributes: {
                title: 'Title 1',
                body: 'Body 1',
                publish_at: @publish_at
              },
              relationships: {
                author: {
                  data: { id: '1', type: 'authors' }
                },
                comments: {
                  data: [
                    { id: '7', type: 'comments' },
                    { id: '12', type: 'comments' }
                  ]
                }
              },
              links: {
                self: 'http://example.com/posts/1337',
                post_authors: 'http://example.com/posts/1337/authors',
                subscriber_comments: 'http://example.com/posts/1337/comments'
              },
              meta: { rating: 5, favorite_count: 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_success_document_key_transform_undefined
          assert_raises NoMethodError do
            serialize_resource(@post, options(:zoot, serializer: PostSerializer))
          end
        end

        def test_success_document_key_transform_camel
          result = serialize_resource(@post, options(:camel, serializer: PostSerializer))
          expected_result = {
            Data: {
              Id: '1337',
              Type: 'posts',
              Attributes: {
                Title: 'Title 1',
                Body: 'Body 1',
                PublishAt: @publish_at
              },
              Relationships: {
                Author: {
                  Data: { Id: '1', Type: 'authors' }
                },
                Comments: {
                  Data: [
                    { Id: '7', Type: 'comments' },
                    { Id: '12', Type: 'comments' }
                  ]
                }
              },
              Links: {
                Self: 'http://example.com/posts/1337',
                PostAuthors: 'http://example.com/posts/1337/authors',
                SubscriberComments: 'http://example.com/posts/1337/comments'
              },
              Meta: { Rating: 5, FavoriteCount: 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_success_document_key_transform_camel_lower
          result = serialize_resource(@post, options(:camel_lower, serializer: PostSerializer))
          expected_result = {
            data: {
              id: '1337',
              type: 'posts',
              attributes: {
                title: 'Title 1',
                body: 'Body 1',
                publishAt: @publish_at
              },
              relationships: {
                author: {
                  data: { id: '1', type: 'authors' }
                },
                comments: {
                  data: [
                    { id: '7', type: 'comments' },
                    { id: '12', type: 'comments' }
                  ]
                }
              },
              links: {
                self: 'http://example.com/posts/1337',
                postAuthors: 'http://example.com/posts/1337/authors',
                subscriberComments: 'http://example.com/posts/1337/comments'
              },
              meta: { rating: 5, favoriteCount: 10 }
            }
          }
          assert_equal(expected_result, result)
        end

        def test_error_document_key_transform_default
          result = serialize_resource(@error_resource, options(nil, serializer: ActiveModel::Serializer::ErrorSerializer))
          expected_errors_object = {
            errors: [
              {
                source: { pointer: '/data/attributes/published_at' },
                detail: 'must be in the future'
              },
              {
                source: { pointer: '/data/attributes/title' },
                detail: 'must be longer'
              }
            ]
          }
          assert_equal expected_errors_object, result
        end

        def test_error_document_key_transform_global_config
          result = with_config(key_transform: :camel) do
            serialize_resource(@error_resource, options(nil, serializer: ActiveModel::Serializer::ErrorSerializer))
          end
          expected_errors_object = {
            Errors: [
              {
                Source: { Pointer: '/data/attributes/published_at' },
                Detail: 'must be in the future'
              },
              {
                Source: { Pointer: '/data/attributes/title' },
                Detail: 'must be longer'
              }
            ]
          }
          assert_equal expected_errors_object, result
        end

        def test_error_document_key_transform_serialization_ctx_overrides_global
          result = with_config(key_transform: :camel_lower) do
            serialize_resource(@error_resource, options(:camel, serializer: ActiveModel::Serializer::ErrorSerializer))
          end
          expected_errors_object = {
            Errors: [
              {
                Source: { Pointer: '/data/attributes/published_at' },
                Detail: 'must be in the future'
              },
              {
                Source: { Pointer: '/data/attributes/title' },
                Detail: 'must be longer'
              }
            ]
          }
          assert_equal expected_errors_object, result
        end

        def test_error_document_key_transform_dashed
          result = serialize_resource(@error_resource, options(:dashed, serializer: ActiveModel::Serializer::ErrorSerializer))
          expected_errors_object = {
            errors: [
              {
                source: { pointer: '/data/attributes/published_at' },
                detail: 'must be in the future'
              },
              {
                source: { pointer: '/data/attributes/title' },
                detail: 'must be longer'
              }
            ]
          }
          assert_equal expected_errors_object, result
        end

        def test_error_document_key_transform_unaltered
          result = serialize_resource(@error_resource, options(:unaltered, serializer: ActiveModel::Serializer::ErrorSerializer))
          expected_errors_object = {
            errors: [
              {
                source: { pointer: '/data/attributes/published_at' },
                detail: 'must be in the future'
              },
              {
                source: { pointer: '/data/attributes/title' },
                detail: 'must be longer'
              }
            ]
          }
          assert_equal expected_errors_object, result
        end

        def test_error_document_key_transform_undefined
          assert_raises NoMethodError do
            serialize_resource(@error_resource, options(:krazy, serializer: ActiveModel::Serializer::ErrorSerializer))
          end
        end

        def test_error_document_key_transform_camel
          result = serialize_resource(@error_resource, options(:camel, serializer: ActiveModel::Serializer::ErrorSerializer))
          expected_errors_object = {
            Errors:
              [
                {
                  Source: { Pointer: '/data/attributes/published_at' },
                  Detail: 'must be in the future'
                },
                {
                  Source: { Pointer: '/data/attributes/title' },
                  Detail: 'must be longer'
                }
              ]
          }
          assert_equal expected_errors_object, result
        end

        def test_error_document_key_transform_camel_lower
          result = serialize_resource(@error_resource, options(:camel_lower, serializer: ActiveModel::Serializer::ErrorSerializer))
          expected_errors_object = {
            errors: [
              {
                source: { pointer: '/data/attributes/published_at' },
                detail: 'must be in the future'
              },
              {
                source: { pointer: '/data/attributes/title' },
                detail: 'must be longer'
              }
            ]
          }
          assert_equal expected_errors_object, result
        end

        private

        def options(key_transform = nil, extra_options = {})
          context = Minitest::Mock.new
          context.expect(:request_url, URI)
          context.expect(:query_parameters, {})
          context.expect(:key_transform, key_transform)
          context.expect(:url_helpers, Rails.application.routes.url_helpers)
          {
            serialization_context: context,
            adapter: :json_api
          }.merge(extra_options)
        end

        def serialize_resource(resource, options)
          ActiveModel::SerializableResource.new(resource, options).as_json
        end
      end
    end
  end
end

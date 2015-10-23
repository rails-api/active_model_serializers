require 'test_helper'

module ActionController
  module Serialization
    class JsonApiHasOneLinksTest < ActionController::TestCase
      class LinkTagSerializer < ActiveModel::Serializer
        has_one :post, links: { related: proc { |object, name| "http://test.host/tags/#{object.id}/#{name}" } }, data: false
      end

      class MyController < ActionController::Base
        def render_resource_with_has_one_association
          @tag = Tag.new(id: 1)
          @tag.post = Post.new(id: 1)
          render json: @tag, adapter: :json_api, serializer: LinkTagSerializer
        end
      end

      tests MyController

      def test_render_resource_with_has_one_association
        get :render_resource_with_has_one_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              post: {
                links: {
                  related: 'http://test.host/tags/1/post'
                }
              }
            }
          }
        }
        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasOneLinksWithIncludedTest < ActionController::TestCase
      class CommentSerializer < ActiveModel::Serializer
        attribute :text
      end

      class LinkPostSerializer < ActiveModel::Serializer
        has_one :comment, links: { related: 'comment-link' }, data: true, serializer: CommentSerializer
      end

      class LinkTagSerializer < ActiveModel::Serializer
        has_one :post, links: { related: 'post-link' }, data: true, serializer: LinkPostSerializer
      end

      class MyController < ActionController::Base
        def render_resource_with_has_one_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @comment = Comment.new(id: 3, text: nil)
          @post.comment = @comment
          @tag.post = @post
          render json: @tag,
                 adapter: :json_api,
                 serializer: LinkTagSerializer,
                 include: 'post,post.comment'
        end
      end

      tests MyController

      def test_render_resource_with_has_one_association
        get :render_resource_with_has_one_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              post: {
                data: { id: '2', type: 'posts' },
                links: {
                  related: 'post-link'
                }
              }
            }
          },
          included: [
            {
              id: '2',
              type: 'posts',
              relationships: {
                comment: {
                  data: { id: '3', type: 'comments' },
                  links: {
                    related: 'comment-link'
                  }
                }
              }
            },
            {
              id: '3',
              type: 'comments',
              attributes: {
                text: nil
              }
            }
          ]
        }

        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasOneLinksWithIncludedAndNoDataTest < ActionController::TestCase
      class LinkPostSerializer < ActiveModel::Serializer
        has_one :comment, links: { related: 'comment-link' }, data: false
      end

      class LinkTagSerializer < ActiveModel::Serializer
        has_one :post, links: { related: 'post-link' }, data: false, serializer: LinkPostSerializer
      end

      class MyController < ActionController::Base
        def render_resource_with_has_one_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @comment = Comment.new(id: 3, text: nil)
          @post.comment = @comment
          @tag.post = @post
          render json: @tag,
                 adapter: :json_api,
                 serializer: LinkTagSerializer,
                 include: 'post,post.comment'
        end
      end

      tests MyController

      def test_render_resource_with_has_one_association
        get :render_resource_with_has_one_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              post: {
                links: {
                  related: 'post-link'
                }
              }
            }
          }
        }

        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasOneLinksWithNestedIncludedAndNoDataTest < ActionController::TestCase
      class LinkPostSerializer < ActiveModel::Serializer
        has_one :comment, links: { related: 'comment-link' }, data: false
      end

      class LinkTagSerializer < ActiveModel::Serializer
        has_one :post, links: { related: 'post-link' }, data: true, serializer: LinkPostSerializer
      end

      class MyController < ActionController::Base
        def render_resource_with_has_one_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @comment = Comment.new(id: 3, text: nil)
          @post.comment = @comment
          @tag.post = @post
          render json: @tag,
                 adapter: :json_api,
                 serializer: LinkTagSerializer,
                 include: 'post,post.comment'
        end
      end

      tests MyController

      def test_render_resource_with_has_one_association
        get :render_resource_with_has_one_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              post: {
                data: { id: '2', type: 'posts' },
                links: {
                  related: 'post-link'
                }
              }
            }
          },
          included: [
            {
              id: '2',
              type: 'posts',
              relationships: {
                comment: {
                  links: {
                    related: 'comment-link'
                  }
                }
              }
            }
          ]
        }

        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasOneLinksWithDataTest < ActionController::TestCase
      class LinkTagSerializer < ActiveModel::Serializer
        has_one :post, links: { related: proc { |object, name| "http://test.host/tags/#{object.id}/#{name}" } }
      end

      class MyController < ActionController::Base
        def render_resource_with_has_one_association
          @tag = Tag.new(id: 1)
          @tag.post = Post.new(id: 1)
          render json: @tag, adapter: :json_api, serializer: LinkTagSerializer
        end
      end

      tests MyController

      def test_render_resource_with_has_one_association
        get :render_resource_with_has_one_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              post: {
                data: { id: '1', type: 'posts' },
                links: {
                  related: 'http://test.host/tags/1/post'
                }
              }
            }
          }
        }
        assert_equal expected.to_json, response.body
      end
    end
  end
end

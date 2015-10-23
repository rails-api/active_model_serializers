require 'test_helper'

module ActionController
  module Serialization
    class JsonApiHasManyLinksTest < ActionController::TestCase
      class LinkTagSerializer < ActiveModel::Serializer
        has_many :posts, links: { related: proc { |object, name| "http://test.host/tags/#{object.id}/#{name}" } }, data: false
      end

      class MyController < ActionController::Base
        def render_resource_with_has_many_association
          @tag = Tag.new(id: 1)
          @tag.posts = []
          render json: @tag, adapter: :json_api, serializer: LinkTagSerializer
        end
      end

      tests MyController

      def test_render_resource_with_has_many_association
        get :render_resource_with_has_many_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              posts: {
                links: {
                  related: 'http://test.host/tags/1/posts'
                }
              }
            }
          }
        }
        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasManyLinksWithIncludedTest < ActionController::TestCase
      class CommentSerializer < ActiveModel::Serializer
        attribute :text
      end

      class LinkPostSerializer < ActiveModel::Serializer
        has_many :comments, links: { related: 'comments-link' }, data: true, serializer: CommentSerializer
      end

      class LinkTagSerializer < ActiveModel::Serializer
        has_many :posts, links: { related: 'posts-link' }, data: true, serializer: LinkPostSerializer
      end

      class MyController < ActionController::Base
        def render_resource_with_has_many_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @comment = Comment.new(id: 3, text: nil)
          @post.comments = [@comment]
          @tag.posts = [@post]
          render json: @tag,
                 adapter: :json_api,
                 serializer: LinkTagSerializer,
                 include: 'posts,posts.comments'
        end
      end

      tests MyController

      def test_render_resource_with_has_many_association
        get :render_resource_with_has_many_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              posts: {
                data: [{ id: '2', type: 'posts' }],
                links: {
                  related: 'posts-link'
                }
              }
            }
          },
          included: [
            {
              id: '2',
              type: 'posts',
              relationships: {
                comments: {
                  data: [{ id: '3', type: 'comments' }],
                  links: {
                    related: 'comments-link'
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

    class JsonApiHasManyLinksWithIncludedAndNoDataTest < ActionController::TestCase
      class LinkPostSerializer < ActiveModel::Serializer
        has_many :comments, links: { related: 'comments-link' }, data: false
      end

      class LinkTagSerializer < ActiveModel::Serializer
        has_many :posts, links: { related: 'posts-link' }, data: false, serializer: LinkPostSerializer
      end

      class MyController < ActionController::Base
        def render_resource_with_has_many_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @comment = Comment.new(id: 3, text: nil)
          @post.comments = [@comment]
          @tag.posts = [@post]
          render json: @tag,
                 adapter: :json_api,
                 serializer: LinkTagSerializer,
                 include: 'posts,posts.comments'
        end
      end

      tests MyController

      def test_render_resource_with_has_many_association
        get :render_resource_with_has_many_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              posts: {
                links: {
                  related: 'posts-link'
                }
              }
            }
          }
        }

        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasManyLinksWithNestedIncludedAndNoDataTest < ActionController::TestCase
      class LinkPostSerializer < ActiveModel::Serializer
        has_many :comments, links: { related: 'comments-link' }, data: false
      end

      class LinkTagSerializer < ActiveModel::Serializer
        has_many :posts, links: { related: 'posts-link' }, data: true, serializer: LinkPostSerializer
      end

      class MyController < ActionController::Base
        def render_resource_with_has_many_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @comment = Comment.new(id: 3, text: nil)
          @post.comments = [@comment]
          @tag.posts = [@post]
          render json: @tag,
                 adapter: :json_api,
                 serializer: LinkTagSerializer,
                 include: 'posts,posts.comments'
        end
      end

      tests MyController

      def test_render_resource_with_has_many_association
        get :render_resource_with_has_many_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              posts: {
                data: [{ id: '2', type: 'posts' }],
                links: {
                  related: 'posts-link'
                }
              }
            }
          },
          included: [
            {
              id: '2',
              type: 'posts',
              relationships: {
                comments: {
                  links: {
                    related: 'comments-link'
                  }
                }
              }
            }
          ]
        }

        assert_equal expected.to_json, response.body
      end
    end

    class JsonApiHasManyLinksWithDataTest < ActionController::TestCase
      class LinkTagSerializer < ActiveModel::Serializer
        has_many :posts, links: { related: proc { |object, name| "http://test.host/tags/#{object.id}/#{name}" } }
      end

      class MyController < ActionController::Base
        def render_resource_with_has_many_association
          @tag = Tag.new(id: 1)
          @post = Post.new(id: 2)
          @tag.posts = [@post]
          render json: @tag, adapter: :json_api, serializer: LinkTagSerializer
        end
      end

      tests MyController

      def test_render_resource_with_has_many_association
        get :render_resource_with_has_many_association
        expected = {
          data: {
            id: '1',
            type: 'tags',
            relationships: {
              posts: {
                data: [{ id: '2', type: 'posts' }],
                links: {
                  related: 'http://test.host/tags/1/posts'
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

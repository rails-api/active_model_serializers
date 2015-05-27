require 'test_helper'

module ActionController
  module Serialization
    class JsonApiLinkedTest < ActionController::TestCase
      class MyController < ActionController::Base
        def setup_post
          ActionController::Base.cache_store.clear
          @role1 = Role.new(id: 1, name: 'admin')
          @role2 = Role.new(id: 2, name: 'colab')
          @author = Author.new(id: 1, name: 'Steve K.')
          @author.posts = []
          @author.bio = nil
          @author.roles = [@role1, @role2]
          @role1.author = @author
          @role2.author = @author
          @author2 = Author.new(id: 2, name: 'Anonymous')
          @author2.posts = []
          @author2.bio = nil
          @author2.roles = []
          @post = Post.new(id: 1, title: 'New Post', body: 'Body')
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @post.comments = [@first_comment, @second_comment]
          @post.author = @author
          @first_comment.post = @post
          @first_comment.author = @author2
          @second_comment.post = @post
          @second_comment.author = nil
          @post2 = Post.new(id: 2, title: "Another Post", body: "Body")
          @post2.author = @author
          @post2.comments = []
          @blog = Blog.new(id: 1, name: "My Blog!!")
          @post.blog = @blog
          @post2.blog = @blog
        end

        def render_resource_without_include
          setup_post
          render json: @post, adapter: :json_api
        end

        def render_resource_with_include
          setup_post
          render json: @post, include: 'author', adapter: :json_api
        end

        def render_resource_with_nested_include
          setup_post
          render json: @post, include: 'comments.author', adapter: :json_api
        end

        def render_resource_with_nested_has_many_include
          setup_post
          render json: @post, include: ['author', 'author.roles'], adapter: :json_api
        end

        def render_resource_with_missing_nested_has_many_include
          setup_post
          @post.author = @author2 # author2 has no roles.
          render json: @post, include: 'author,author.roles', adapter: :json_api
        end

        def render_collection_with_missing_nested_has_many_include
          setup_post
          @post.author = @author2
          render json: [@post, @post2], include: 'author,author.roles', adapter: :json_api
        end

        def render_collection_without_include
          setup_post
          render json: [@post], adapter: :json_api
        end

        def render_collection_with_include
          setup_post
          render json: [@post], include: ['author', 'comments'], adapter: :json_api
        end
      end

      tests MyController

      def test_render_resource_without_include
        get :render_resource_without_include
        response = JSON.parse(@response.body)
        refute response.key? 'included'
      end

      def test_render_resource_with_include
        get :render_resource_with_include
        response = JSON.parse(@response.body)
        assert response.key? 'included'
        assert_equal 1, response['included'].size
        assert_equal 'Steve K.', response['included'].first['attributes']['name']
      end

      def test_render_resource_with_nested_has_many_include
        get :render_resource_with_nested_has_many_include
        response = JSON.parse(@response.body)
        expected_linked = [
          {
            "id" => "1",
            "type" => "authors",
            "attributes" => {
              "name" => "Steve K."
            },
            "relationships" => {
              "posts" => { "data" => [] },
              "roles" => { "data" => [{ "type" =>"roles", "id" => "1" }, { "type" =>"roles", "id" => "2" }] },
              "bio" => { "data" => nil }
            }
          }, {
            "id" => "1",
            "type" => "roles",
            "attributes" => {
              "name" => "admin",
              "description" => nil,
              "slug" => "admin-1"
            },
            "relationships" => {
              "author" => { "data" => { "type" =>"authors", "id" => "1" } }
            }
          }, {
            "id" => "2",
            "type" => "roles",
            "attributes" => {
              "name" => "colab",
              "description" => nil,
              "slug" => "colab-2"
            },
            "relationships" => {
              "author" => { "data" => { "type" =>"authors", "id" => "1" } }
            }
          }
        ]
        assert_equal expected_linked, response['included']
      end

      def test_render_resource_with_nested_include
        get :render_resource_with_nested_include
        response = JSON.parse(@response.body)
        assert response.key? 'included'
        assert_equal 1, response['included'].size
        assert_equal 'Anonymous', response['included'].first['attributes']['name']
      end

      def test_render_collection_without_include
        get :render_collection_without_include
        response = JSON.parse(@response.body)
        refute response.key? 'included'
      end

      def test_render_collection_with_include
        get :render_collection_with_include
        response = JSON.parse(@response.body)
        assert response.key? 'included'
      end

      def test_render_resource_with_nested_attributes_even_when_missing_associations
        get :render_resource_with_missing_nested_has_many_include
        response = JSON.parse(@response.body)
        assert response.key? 'included'
        refute has_type?(response['included'], 'roles')
      end

      def test_render_collection_with_missing_nested_has_many_include
        get :render_collection_with_missing_nested_has_many_include
        response = JSON.parse(@response.body)
        assert response.key? 'included'
        assert has_type?(response['included'], 'roles')
      end

      def has_type?(collection, value)
        collection.detect { |i| i['type'] == value}
      end

    end
  end
end

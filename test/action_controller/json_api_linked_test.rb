require 'test_helper'

module ActionController
  module Serialization
    class JsonApiLinkedTest < ActionController::TestCase
      class MyController < ActionController::Base
        def setup_post
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
          render json: @post, include: 'author,author.roles', adapter: :json_api
        end

        def render_collection_without_include
          setup_post
          render json: [@post], adapter: :json_api
        end

        def render_collection_with_include
          setup_post
          render json: [@post], include: 'author,comments', adapter: :json_api
        end
      end

      tests MyController

      def test_render_resource_without_include
        get :render_resource_without_include
        response = JSON.parse(@response.body)
        refute response.key? 'linked'
      end

      def test_render_resource_with_include
        get :render_resource_with_include
        response = JSON.parse(@response.body)
        assert response.key? 'linked'
        assert_equal 1, response['linked']['authors'].size
        assert_equal 'Steve K.', response['linked']['authors'].first['name']
      end

      def test_render_resource_with_nested_has_many_include
        get :render_resource_with_nested_has_many_include
        response = JSON.parse(@response.body)
        expected_linked = {
          "authors" => [{
            "id" => "1",
            "name" => "Steve K.",
            "links" => {
              "posts" => [],
              "roles" => ["1", "2"],
              "bio" => nil
            }
          }],
          "roles"=>[{
            "id" => "1",
            "name" => "admin",
            "links" => {
              "author" => "1"
            }
          }, {
            "id" => "2",
            "name" => "colab",
            "links" => {
              "author" => "1"
            }
          }]
        }
        assert_equal expected_linked, response['linked']
      end

      def test_render_resource_with_nested_include
        get :render_resource_with_nested_include
        response = JSON.parse(@response.body)
        assert response.key? 'linked'
        assert_equal 1, response['linked']['authors'].size
        assert_equal 'Anonymous', response['linked']['authors'].first['name']
      end

      def test_render_collection_without_include
        get :render_collection_without_include
        response = JSON.parse(@response.body)
        refute response.key? 'linked'
      end

      def test_render_collection_with_include
        get :render_collection_with_include
        response = JSON.parse(@response.body)
        assert response.key? 'linked'
      end
    end
  end
end

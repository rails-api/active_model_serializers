require 'test_helper'

module ActionController
  module Serialization
    class FlatJson
      class NestedTest < ActionController::TestCase
        class FlatJsonNestedTestController < ActionController::Base

          # now PostSerializer, because the default hardcodes the
          # blog relationship
          PostSerializer = Class.new(ActiveModel::Serializer) do
            cache key: 'post', expires_in: 0.1, skip_digest: true
            attributes :id, :title, :body

            has_many :comments
            belongs_to :blog
            belongs_to :author

            def custom_options
              instance_options
            end
          end


          def setup_data
            ActionController::Base.cache_store.clear

            @author = Author.new(id: 1, name: 'Steve K.')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT', author: @author)
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT', author: @author)
            @post.comments = [@first_comment, @second_comment]
            @post.author = @author
            @author.posts = [@post]
            @author.roles = []
            @author.bio = nil
            @first_comment.post = @post
            @second_comment.post = @post
            @blog = Blog.new(id: 1, name: 'My Blog!!', writer: @author)
            @post.blog = @blog
            @blog.articles = [@post]
          end

          def render_objects_in_json_root
            setup_data
            render json: @post,
                   include: [:blog, :author, comments: [:post, :author]],
                   adapter: :flat_json,
                   serializer: PostSerializer
          end

          def render_author
            setup_data
            render json: @author, adapter: :flat_json
          end
        end

        tests FlatJsonNestedTestController

        def test_render_author
          get :render_author
          response = JSON.parse(@response.body)

          expected = {
            author: {
              id: "1",
              name: 'Steve K.',
              post_ids: ["42"],
              role_ids: [],
              bio_id: nil
            }
          }.to_json
          expected = JSON.parse(expected)

          assert_equal(expected, response)
        end

        def test_render_objects_objects_in_json_root
          get :render_objects_in_json_root
          response = JSON.parse(@response.body)

          expected = {
            'post' => {
              'id' => "42",
              'title' => 'New Post',
              'body' => 'Body',
              'comment_ids' => ["1", "2"],
              'blog_id' => "999",
              'author_id' => "1"
            },
            'author' => {
              'id' => "1",
              'name' => 'Steve K.',
              'post_ids' => ['42'],
              'role_ids' => [],
              'bio_id' => nil
            },
            'comments' => [
              { 'id' => "1", 'body' => 'ZOMG A COMMENT', 'post_id' => "42", 'author_id' => "1" },
              { 'id' => "2", 'body' => 'ZOMG ANOTHER COMMENT', 'post_id' => "42", 'author_id' => "1" }
            ],
            'blog' => {
              'id' => "1",
              'name' => 'My Blog!!',
              'writer_id' => '1',
              'article_ids' => ['42']
            }
           }


          assert_equal(expected, response)
        end
      end
    end
  end
end

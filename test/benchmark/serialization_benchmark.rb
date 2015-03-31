require 'test_helper'

module ActionController
  module Serialization
    class SerializerTest < ActionController::TestCase
      class PostController < ActionController::Base

        def render_with_cache_enable
          comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
          author  = Author.new(id: 1, name: 'Joao Moura.')
          post    = Post.new({ id: 1, title: 'New Post', blog:nil, body: 'Body', comments: [comment], author: author })

          render json: post
        end
      end

      tests PostController

      def test_render_with_cache_enable
        ActionController::Base.cache_store.clear
        get :render_with_cache_enable

        expected = {
          id: 1,
          title: 'New Post',
          body: 'Body',
          comments: [
            {
              id: 1,
              body: 'ZOMG A COMMENT' }
          ],
          blog: {
            id: 999,
            name: 'Custom blog'
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body

        get :render_with_cache_enable
        assert_equal expected.to_json, @response.body
      end
    end
  end
end

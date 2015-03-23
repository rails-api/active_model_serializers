require 'test_helper'

module ActionController
  module Serialization
    class JsonApiHasManyUrlTest < ActionController::TestCase
      class MyController < ActionController::Base

        def render_resource_with_url_association
          @tag = Tag.new(id: 1)
          @tag.posts = []
          render json: @tag, adapter: :json_api
        end
      end

      tests MyController

      def test_render_resource_with_url_association
        get :render_resource_with_url_association
        response = JSON.parse(@response.body)
        assert response.key? 'tags'
        assert response['tags'].key? 'links'
        assert response['tags']['links'].key? 'posts'
        assert_equal 'http://test.host/tags/1/posts', response['tags']['links']['posts']
      end
    end
  end
end

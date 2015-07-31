require 'test_helper'

module ActionController
  module Serialization
    class JsonApiHasManyUrlTest < ActionController::TestCase
      class MyController < ActionController::Base

        def render_resource_with_url_association
          @tag = Tag.new(id: 1)
          @tag.posts = []
          render json: @tag, adapter: :json_api, serializer: LinkTagSerializer
        end
      end

      tests MyController

      def test_render_resource_with_url_association
        get :render_resource_with_url_association
        expected = {
          data: {
            id: "1",
            type: "tags",
            relationships: {
              posts: {
                links: {
                  related: "http://test.host/tags/1/posts"
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
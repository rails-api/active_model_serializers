require 'test_helper'

module ActionController
  module Serialization
    class JsonApiHasManyMetaTest < ActionController::TestCase
      class MetaTagSerializer < ActiveModel::Serializer
        has_many :posts, meta: proc { { page: '1' } }
      end

      class MyController < ActionController::Base
        def render_resource_with_has_many_association
          @tag = Tag.new(id: 1)
          @tag.posts = []
          render json: @tag, adapter: :json_api, serializer: MetaTagSerializer
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
                data: [],
                meta: {
                  page: '1'
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

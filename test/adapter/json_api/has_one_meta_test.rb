require 'test_helper'

module ActionController
  module Serialization
    class JsonApiHasOneMetaTest < ActionController::TestCase
      class MetaTagSerializer < ActiveModel::Serializer
        has_one :post, meta: proc { { deleted: true } }
      end

      class MyController < ActionController::Base
        def render_resource_with_has_one_association
          @tag = Tag.new(id: 1)
          @tag.post = Post.new(id: 1)
          render json: @tag, adapter: :json_api, serializer: MetaTagSerializer
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
                meta: {
                  deleted: true
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

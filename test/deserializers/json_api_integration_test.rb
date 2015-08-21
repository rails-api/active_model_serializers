require 'test_helper'

module ActionController
  module Serializer
    class JsonApiIntegrationTest < ActionController::TestCase
      class JsonApiIntegrationTestController < ActionController::Base
        def create_resource
          with_adapter ActiveModel::Serializer::Adapter::JsonApi do
            @post = Post.create(post_params)
            render json: @post, status: :created
          end
        end

        private

        def post_params
          PostSerializer.deserialize(params)
        end

        def with_adapter(adapter)
          old_adapter = ActiveModel::Serializer.config.adapter
          # JSON-API adapter sets root by default
          ActiveModel::Serializer.config.adapter = adapter
          yield
        ensure
          ActiveModel::Serializer.config.adapter = old_adapter
        end
      end

      tests JsonApiIntegrationTestController

      def test_json_api_deserialization_on_create
        post_params = {
          data: {
            type: 'posts',
            attributes: {
              title: 'ZOMG a post title',
              body: 'ZOMG now a post body'
            }
          }
        }
        post :create_resource, post_params
        assert_equal post_params[:data][:attributes].to_json, response.body
      end

      def test_json_api_deserialization_on_create_with_associations
        post_params = {
          data: {
            type: 'posts',
            attributes: {
              title: 'ZOMG a post title',
              body: 'ZOMG now a post body'
            },
            relationships: {
              comments:{
                data:{
                  id: 1,
                  type: 'comment'
                }
              }
            }
          }
        }
        post :create_resource, post_params
        assert_equal post_params[:data][:attributes].to_json, response.body
      end
    end
  end
end

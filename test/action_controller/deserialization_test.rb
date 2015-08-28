require 'test_helper'

module ActionController
  module Serializer
    class ImplicitDeserializerTest < ActionController::TestCase
      class ImplicitDeserializerTestController < ActionController::Base
        def create_resource
          with_adapter :json_api do
            @post = ARModels::Post.create(create_params)
            render json: @post, status: :created
          end
        end

        private

        def create_params
          ARModels::PostSerializer.deserialize(params)
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

      tests ImplicitDeserializerTestController

      def test_json_api_deserialization_on_create
        payload = {
          data: {
            type: 'posts',
            attributes: {
              title: 'Title 1',
              body: 'Body 1'
            }
          }
        }

        post :create_resource, payload
        new_post = JSON.parse(@response.body)

        assert_equal payload[:data][:attributes][:title], new_post['data']['attributes']['title']
        assert_equal payload[:data][:attributes][:body], new_post['data']['attributes']['body']
      end

      def test_json_api_deserialization_on_create_with_associations
        comment = ARModels::Comment.create(contents: "Comment 1")
        payload = {
          data: {
            type: 'posts',
            attributes: {
              title: 'Title 1',
              body: 'Body 1'
            },
            relationships: {
              comments: {
                data: [{ id: comment.id, type: 'comments' }]
              }
            }
          }
        }

        post :create_resource, payload
        new_post = JSON.parse(@response.body)

        assert_equal 1, new_post['data']['relationships']['comments']['data'].length
        assert_equal "#{comment.id}", new_post['data']['relationships']['comments']['data'][0]['id']
        assert_equal 'ar_models_comments', new_post['data']['relationships']['comments']['data'][0]['type']
      end
    end
  end
end

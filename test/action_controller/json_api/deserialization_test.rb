require 'test_helper'

module ActionController
  module Serialization
    class JsonApi
      class DeserializationTest < ActionController::TestCase
        class DeserializationTestController < ActionController::Base
          def render_parsed_payload
            parsed_hash = ActiveModelSerializers::Deserialization.jsonapi_parse(params)
            render json: parsed_hash
          end
        end

        tests DeserializationTestController

        def test_deserialization
          hash = {
            'data' => {
              'type' => 'photos',
              'id' => 'zorglub',
              'attributes' => {
                'title' => 'Ember Hamster',
                'src' => 'http://example.com/images/productivity.png',
                'photo-url' => 'http://placehold.it/350x150'
              },
              'relationships' => {
                'author' => {
                  'data' => nil
                },
                'photographer' => {
                  'data' => { 'type' => 'people', 'id' => '9' }
                },
                'comments' => {
                  'data' => [
                    { 'type' => 'comments', 'id' => '1' },
                    { 'type' => 'comments', 'id' => '2' }
                  ]
                },
                'two-words' => {
                  'data' => [
                    { 'type' => 'two-words', 'id' => '1' }
                  ]
                }
              }
            }
          }

          post :render_parsed_payload, params: hash

          response = JSON.parse(@response.body)
          expected = {
            'title' => 'Ember Hamster',
            'src' => 'http://example.com/images/productivity.png',
            'photo_url' => 'http://placehold.it/350x150',
            'id' => 'zorglub',
            'author_id' => nil,
            'photographer_id' => '9',
            'comment_ids' => %w(1 2),
            'two_word_ids' => %w(1)
          }

          assert_equal(expected, response)
        end
      end
    end
  end
end

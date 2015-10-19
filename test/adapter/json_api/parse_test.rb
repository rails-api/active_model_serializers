require 'test_helper'
module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ParseTest < Minitest::Test
          def setup
            @hash = {
              'data' => {
                'type' => 'photos',
                'id' => 'zorglub',
                'attributes' => {
                  'title' => 'Ember Hamster',
                  'src' => 'http://example.com/images/productivity.png'
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
                  }
                }
              }
            }
            @expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              author_id: nil,
              photographer_id: '9',
              comment_ids: %w(1 2)
            }
          end

          def test_hash
            parsed_hash = ActiveModel::Serializer::Adapter::JsonApi.parse(@hash)
            assert_equal(@expected, parsed_hash)
          end

          def test_parameters
            parameters = ActionController::Parameters.new(@hash)
            parsed_hash = ActiveModel::Serializer::Adapter::JsonApi.parse(parameters)
            assert_equal(@expected, parsed_hash)
          end

          def test_illformed_payload
            parsed_hash = ActiveModel::Serializer::Adapter::JsonApi.parse({})
            assert_equal({}, parsed_hash)
          end
        end
      end
    end
  end
end

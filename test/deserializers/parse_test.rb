require 'test_helper'

module ActiveModel
  class Serializer
    class ParseTest < Minitest::Test
      def test_parse_attributes
        payload = {
          'data' => {
            'type' => 'posts',
            'attributes' => {
              'title' => 'Title 1',
              'body' => 'Body 1'
            }
          }
        }

        object = ActiveModel::Serializer::Adapter::JsonApi.parse(payload['data'])

        expected = {
          'title' => 'Title 1',
          'body' => 'Body 1'
        }

        assert_equal(expected, object)
      end

      def test_parse_association_to_one
        payload = {
          'data' => {
            'type' => 'posts',
            'relationships' => {
              'author' => {
                'data' => { 'type' => 'authors', 'id' => 1 }
              }
            }
          }
        }

        object = ActiveModel::Serializer::Adapter::JsonApi.parse(payload['data'])

        expected = {
          'author_id' => 1
        }

        assert_equal(expected, object)
      end

      def test_parse_null_association_to_one
        payload = {
          'data' => {
            'type' => 'posts',
            'relationships' => {
              'author' => {
                'data' => nil
              }
            }
          }
        }

        object = ActiveModel::Serializer::Adapter::JsonApi.parse(payload['data'])

        expected = {
          'author_id' => nil
        }

        assert_equal(expected, object)
      end

      def test_parse_association_to_many
        payload = {
          'data' => {
            'type' => 'posts',
            'relationships' => {
              'comments' => {
                'data' => [{ 'type' => 'comments', 'id' => 1 },
                           { 'type' => 'comments', 'id' => 2 }]
              }
            }
          }
        }

        object = ActiveModel::Serializer::Adapter::JsonApi.parse(payload['data'])

        expected = {
          'comment_ids' => [1, 2]
        }
        assert_equal(expected, object)
      end

      def test_parse_empty_association_to_many
        payload = {
          'data' => {
            'type' => 'posts',
            'relationships' => {
              'comments' => {
                'data' => []
              }
            }
          }
        }

        object = ActiveModel::Serializer::Adapter::JsonApi.parse(payload['data'])

        expected = {
          'comment_ids' => []
        }
        assert_equal(expected, object)
      end
    end
  end
end

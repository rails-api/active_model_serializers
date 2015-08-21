require 'test_helper'

module ActiveModel
  class Serializer
    class SanitizeParamsTest < Minitest::Test
      def with_adapter(adapter)
        old_adapter = ActiveModel::Serializer.config.adapter
        ActiveModel::Serializer.config.adapter = adapter
        yield
      ensure
        ActiveModel::Serializer.config.adapter = old_adapter
      end

      def test_sanitize_attributes
        payload = {
          'data' => {
            'type' => 'posts',
            'attributes' => {
              'title' => 'Title 1',
              'body' => 'Body 1'
            }
          }
        }

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload))
        end

        assert_equal(payload['data'], object)
      end

      def test_sanitize_attributes_whitelist
        payload = {
          'data' => {
            'type' => 'posts',
            'attributes' => {
              'title' => 'Title 1',
              'body' => 'Body 1'
            }
          }
        }

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload),
                                         [:title])
        end

        expected = {
          'type' => 'posts',
          'attributes' => {
            'title' => 'Title 1'
          }
        }

        assert_equal(expected, object)
      end

      def test_sanitize_attributes_whitelist_id_forbidden
        payload = {
          'data' => {
            'type' => 'posts',
            'id' => 1,
            'attributes' => {
              'title' => 'Title 1',
              'body' => 'Body 1'
            }
          }
        }

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload),
                                         [:title])
        end

        expected = {
          'type' => 'posts',
          'attributes' => {
            'title' => 'Title 1'
          }
        }

        assert_equal(expected, object)
      end

      def test_sanitize_attributes_whitelist_id_allowed
        payload = {
          'data' => {
            'type' => 'posts',
            'id' => 1,
            'attributes' => {
              'title' => 'Title 1',
              'body' => 'Body 1'
            }
          }
        }

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload),
                                         [:title, :id])
        end

        expected = {
          'type' => 'posts',
          'id' => 1,
          'attributes' => {
            'title' => 'Title 1'
          }
        }

        assert_equal(expected, object)
      end

      def test_sanitize_associations_whitelist
        payload = {
          'data' => {
            'type' => 'posts',
            'relationships' => {
              'author' => {
                'data' => { 'id' => 1, 'type' => 'authors' }
              },
              'comments' => {
                'data' => [ { 'id' => 1, 'type' => 'comments' },
                            { 'id' => 2, 'type' => 'comments' }]
              }
            }
          }
        }

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload),
                                         [:comments])
        end

        expected = {
          'type' => 'posts',
          'relationships' => {
            'comments' => {
              'data' => [ { 'id' => 1, 'type' => 'comments' },
                          { 'id' => 2, 'type' => 'comments' }]
            }
          }
        }

        assert_equal(expected, object)
      end

      def test_sanitize_association_to_one
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

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload))
        end

        assert_equal(payload['data'], object)
      end

      def test_sanitize_null_association_to_one
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

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload))
        end

        assert_equal(payload['data'], object)
      end

      def test_sanitize_association_to_many
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

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload))
        end

        assert_equal(payload['data'], object)
      end

      def test_sanitize_empty_association_to_many
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

        object = with_adapter :json_api do
          PostSerializer.sanitize_params(ActionController::Parameters.new(payload))
        end

        assert_equal(payload['data'], object)
      end
    end
  end
end

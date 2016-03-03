require 'test_helper'
module ActiveModel
  class Serializer
    module Adapter
      class DeprecationTest < ActiveSupport::TestCase
        class DeprecatedPostSerializer < ActiveModel::Serializer
          attribute :body
        end
        setup do
          post = Post.new(id: 1, body: 'Hello')
          @serializer = DeprecatedPostSerializer.new(post)
        end

        def test_null_adapter_serialization
          assert_equal({}, Null.new(@serializer).as_json)
        end

        def test_json_adapter_serialization
          assert_equal({ post: { body: 'Hello' } }, Json.new(@serializer).as_json)
        end

        def test_jsonapi_adapter_serialization
          expected = {
            data: {
              id: '1',
              type: 'posts',
              attributes: {
                body: 'Hello'
              }
            }
          }
          assert_equal(expected, JsonApi.new(@serializer).as_json)
        end

        def test_attributes_adapter_serialization
          assert_equal({ body: 'Hello' }, Attributes.new(@serializer).as_json)
        end

        def test_null_adapter_deprecation
          assert_deprecated_adapter(Null)
        end

        def test_json_adapter_deprecation
          assert_deprecated_adapter(Json)
        end

        def test_json_api_adapter_deprecation
          assert_deprecated_adapter(JsonApi)
        end

        def test_attributes_adapter_deprecation
          assert_deprecated_adapter(Attributes)
        end

        def test_adapter_create_deprecation
          assert_deprecated do
            Adapter.create(@serializer)
          end
        end

        def test_adapter_adapter_map_deprecation
          assert_deprecated do
            Adapter.adapter_map
          end
        end

        def test_adapter_adapters_deprecation
          assert_deprecated do
            Adapter.adapters
          end
        end

        def test_adapter_adapter_class_deprecation
          assert_deprecated do
            Adapter.adapter_class(:json_api)
          end
        end

        def test_adapter_register_deprecation
          assert_deprecated do
            Adapter.register(:test, Class.new)
            Adapter.adapter_map.delete('test')
          end
        end

        def test_adapter_lookup_deprecation
          assert_deprecated do
            Adapter.lookup(:json_api)
          end
        end

        private

        def assert_deprecated_adapter(adapter)
          assert_deprecated do
            adapter.new(@serializer)
          end
        end

        def assert_deprecated
          message = /deprecated/
          assert_output(nil, message) do
            yield
          end
        end
      end
    end
  end
end

require 'test_helper'
module ActiveModel
  class Serializer
    module Adapter
      class DeprecationTest < ActiveSupport::TestCase
        class PostSerializer < ActiveModel::Serializer
          attribute :body
        end
        setup do
          post = Post.new(id: 1, body: 'Hello')
          @serializer = PostSerializer.new(post)
        end

        test 'null_adapter_serialization_deprecation' do
          expected = {}
          assert_deprecated do
            assert_equal(expected, Null.new(@serializer).as_json)
          end
        end

        test 'json_adapter_serialization_deprecation' do
          expected = { post: { body: 'Hello' } }
          assert_deprecated do
            assert_equal(expected, Json.new(@serializer).as_json)
          end
        end

        test 'jsonapi_adapter_serialization_deprecation' do
          expected = {
            data: {
              id: '1',
              type: 'posts',
              attributes: {
                body: 'Hello'
              }
            }
          }
          assert_deprecated do
            assert_equal(expected, JsonApi.new(@serializer).as_json)
          end
        end

        test 'attributes_adapter_serialization_deprecation' do
          expected = { body: 'Hello' }
          assert_deprecated do
            assert_equal(expected, Attributes.new(@serializer).as_json)
          end
        end

        test 'adapter_create_deprecation' do
          assert_deprecated do
            Adapter.create(@serializer)
          end
        end

        test 'adapter_adapter_map_deprecation' do
          assert_deprecated do
            Adapter.adapter_map
          end
        end

        test 'adapter_adapters_deprecation' do
          assert_deprecated do
            Adapter.adapters
          end
        end

        test 'adapter_adapter_class_deprecation' do
          assert_deprecated do
            Adapter.adapter_class(:json_api)
          end
        end

        test 'adapter_register_deprecation' do
          assert_deprecated do
            begin
              Adapter.register(:test, Class.new)
            ensure
              Adapter.adapter_map.delete('test')
            end
          end
        end

        test 'adapter_lookup_deprecation' do
          assert_deprecated do
            Adapter.lookup(:json_api)
          end
        end

        private

        def assert_deprecated
          assert_output(nil, /deprecated/) do
            yield
          end
        end
      end
    end
  end
end

require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class TypeTest < ActiveSupport::TestCase
          class StringTypeSerializer < ActiveModel::Serializer
            attribute :name
            type 'profile'
          end

          class SymbolTypeSerializer < ActiveModel::Serializer
            attribute :name
            type :profile
          end

          setup do
            @author = Author.new(id: 1, name: 'Steve K.')
          end

          test 'config_plural' do
            with_jsonapi_resource_type :plural do
              assert_type(@author, 'authors')
            end
          end

          test 'config_singular' do
            with_jsonapi_resource_type :singular do
              assert_type(@author, 'author')
            end
          end

          test 'explicit_string_type_value' do
            assert_type(@author, 'profile', serializer: StringTypeSerializer)
          end

          test 'explicit_symbol_type_value' do
            assert_type(@author, 'profile', serializer: SymbolTypeSerializer)
          end

          private

          def assert_type(resource, expected_type, opts = {})
            opts = opts.reverse_merge(adapter: :json_api)
            hash = serializable(resource, opts).serializable_hash
            assert_equal(expected_type, hash.fetch(:data).fetch(:type))
          end

          def with_jsonapi_resource_type(inflection)
            old_inflection = ActiveModelSerializers.config.jsonapi_resource_type
            ActiveModelSerializers.config.jsonapi_resource_type = inflection
            yield
          ensure
            ActiveModelSerializers.config.jsonapi_resource_type = old_inflection
          end
        end
      end
    end
  end
end

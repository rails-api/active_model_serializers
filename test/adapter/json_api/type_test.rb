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

          class ProcTypeSerializer < ActiveModel::Serializer
            type proc { |object|
              "proc-#{object.class.model_name}"
            }
          end

          class BlockTypeSerializer < ActiveModel::Serializer
            type do |object|
              "block-#{object.class.model_name}"
            end
          end

          setup do
            @author = Author.new(id: 1, name: 'Steve K.')
          end

          test 'the type can take a proc' do
            assert_type(@author, 'proc-author', serializer: ProcTypeSerializer)
          end

          test 'the type can take a block' do
            assert_type(@author, 'block-author', serializer: BlockTypeSerializer)
          end

          def test_config_plural
            with_jsonapi_resource_type :plural do
              assert_type(@author, 'authors')
            end
          end

          def test_config_singular
            with_jsonapi_resource_type :singular do
              assert_type(@author, 'author')
            end
          end

          def test_explicit_string_type_value
            assert_type(@author, 'profile', serializer: StringTypeSerializer)
          end

          def test_explicit_symbol_type_value
            assert_type(@author, 'profile', serializer: SymbolTypeSerializer)
          end

          private

          def assert_type(resource, expected_type, opts = {})
            opts = opts.reverse_merge(adapter: :json_api)
            hash = serializable(resource, opts).serializable_hash
            assert_equal(expected_type, hash.fetch(:data).fetch(:type))
          end

          def with_jsonapi_resource_type inflection
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

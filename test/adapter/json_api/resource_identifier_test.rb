require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifierTest < ActiveSupport::TestCase
        class WithDefinedTypeSerializer < ActiveModel::Serializer
          type 'with_defined_type'
        end

        class WithDefinedIdSerializer < ActiveModel::Serializer
          def id
            'special_id'
          end
        end

        class FragmentedSerializer < ActiveModel::Serializer
          cache only: :id

          def id
            'special_id'
          end
        end

        setup do
          @model = Author.new(id: 1, name: 'Steve K.')
          ActionController::Base.cache_store.clear
        end

        def type_for_defined_type
          assert_type(WithDefinedTypeSerializer.new(@model), type: 'with_defined_type')
        end

        def type_for_ignores_key_transform
          # with_key_transform :camel_lower do
            with_type_transform :underscore do
              assert_type(WithDefinedTypeSerializer.new(@model), type: 'with_defined_type')
            end
          # end
        end

        def test_defined_type
          with_key_transform :underscore do
            assert_identifier(WithDefinedTypeSerializer.new(@model), type: 'with_defined_type')
          end
        end

        def test_defined_type_with_differing_transform_from_regular_key_transform
          with_type_transform :underscore do
            assert_identifier(WithDefinedTypeSerializer.new(@model), type: 'with_defined_type')
          end
        end

        def test_singular_type
          assert_with_confing(AuthorSerializer.new(@model), type: 'author', inflection: :singular)
        end

        def test_plural_type
          assert_with_confing(AuthorSerializer.new(@model), type: 'authors', inflection: :plural)
        end

        def test_type_with_namespace
          with_namespace_seperator '--' do
            with_type_transform :underscore do
              spam = Spam::UnrelatedLink.new
              assert_identifier(Spam::UnrelatedLinkSerializer.new(spam), type: 'spam--unrelated_links')
            end
          end
        end

        def test_type_with_custom_namespace
          with_key_transform :underscore do
            spam = Spam::UnrelatedLink.new
            assert_with_confing(Spam::UnrelatedLinkSerializer.new(spam), type: 'spam/unrelated_links', namespace_separator: '/')
          end
        end

        def test_id_defined_on_object
          assert_identifier(AuthorSerializer.new(@model), id: @model.id.to_s)
        end

        def test_id_defined_on_serializer
          assert_identifier(WithDefinedIdSerializer.new(@model), id: 'special_id')
        end

        def test_id_defined_on_fragmented
          assert_identifier(WithDefinedIdSerializer.new(@model), id: 'special_id')
        end

        private

        def assert_with_confing(serializer, opts = {})
          inflection = ActiveModelSerializers.config.jsonapi_resource_type
          namespace_separator = ActiveModelSerializers.config.jsonapi_namespace_separator
          ActiveModelSerializers.config.jsonapi_resource_type = opts.fetch(:inflection, inflection)
          ActiveModelSerializers.config.jsonapi_namespace_separator = opts.fetch(:namespace_separator, namespace_separator)
          assert_identifier(serializer, opts)
        ensure
          ActiveModelSerializers.config.jsonapi_resource_type = inflection
        end

        def assert_type(serializer, opts = {})
          identifier = ResourceIdentifier.new(serializer, opts)

          expected = opts[:type]
          actual = identifier.send(:type_for, serializer)
          assert_equal(expected, actual)
        end

        def assert_identifier(serializer, opts = {})
          identifier = ResourceIdentifier.new(serializer, opts)

          expected = {
            id: opts.fetch(:id, identifier.as_json[:id]),
            type: opts.fetch(:type, identifier.as_json[:type])
          }

          actual = identifier.as_json
          assert_equal(expected, actual)
        end
      end
    end
  end
end

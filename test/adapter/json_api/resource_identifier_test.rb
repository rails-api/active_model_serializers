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

        class FragmentedSerializer < ActiveModel::Serializer; end

        setup do
          @model = Author.new(id: 1, name: 'Steve K.')
          ActionController::Base.cache_store.clear
        end

        def test_defined_type
          assert_identifier(WithDefinedTypeSerializer.new(@model), type: 'with_defined_type')
        end

        def test_singular_type
          assert_with_confing(AuthorSerializer.new(@model), type: 'author', inflection: :singular)
        end

        def test_plural_type
          assert_with_confing(AuthorSerializer.new(@model), type: 'authors', inflection: :plural)
        end

        def test_type_with_namespace
          spam = Spam::UnrelatedLink.new
          assert_identifier(Spam::UnrelatedLinkSerializer.new(spam), type: 'spam--unrelated_links')
        end

        def test_type_with_custom_namespace
          spam = Spam::UnrelatedLink.new
          assert_with_confing(Spam::UnrelatedLinkSerializer.new(spam), type: 'spam/unrelated_links', namespace_separator: '/')
        end

        def test_id_defined_on_object
          assert_identifier(AuthorSerializer.new(@model), id: @model.id.to_s)
        end

        def test_id_defined_on_serializer
          assert_identifier(WithDefinedIdSerializer.new(@model), id: 'special_id')
        end

        def test_id_defined_on_fragmented
          FragmentedSerializer.fragmented(WithDefinedIdSerializer.new(@model))
          assert_identifier(FragmentedSerializer.new(@model), id: 'special_id')
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
          ActiveModelSerializers.config.jsonapi_namespace_separator = namespace_separator
        end

        def assert_identifier(serializer, opts = {})
          identifier = ResourceIdentifier.new(serializer)
          expected = {
            id: opts.fetch(:id, identifier.as_json[:id]),
            type: opts.fetch(:type, identifier.as_json[:type])
          }
          assert_equal(expected, identifier.as_json)
        end
      end
    end
  end
end

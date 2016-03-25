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
          test_type(WithDefinedTypeSerializer, 'with_defined_type')
        end

        def test_singular_type
          test_type_inflection(AuthorSerializer, 'author', :singular)
        end

        def test_plural_type
          test_type_inflection(AuthorSerializer, 'authors', :plural)
        end

        def test_id_defined_on_object
          test_id(AuthorSerializer, @model.id.to_s)
        end

        def test_id_defined_on_serializer
          test_id(WithDefinedIdSerializer, 'special_id')
        end

        def test_id_defined_on_fragmented
          FragmentedSerializer.fragmented(WithDefinedIdSerializer.new(@model))
          test_id(FragmentedSerializer, 'special_id')
        end

        private

        def test_type_inflection(serializer_class, expected_type, inflection)
          original_inflection = ActiveModelSerializers.config.jsonapi_resource_type
          ActiveModelSerializers.config.jsonapi_resource_type = inflection
          test_type(serializer_class, expected_type)
        ensure
          ActiveModelSerializers.config.jsonapi_resource_type = original_inflection
        end

        def test_type(serializer_class, expected_type)
          serializer = serializer_class.new(@model)
          resource_identifier = ResourceIdentifier.new(serializer)
          expected = {
            id: @model.id.to_s,
            type: expected_type
          }

          assert_equal(expected, resource_identifier.as_json)
        end

        def test_id(serializer_class, id)
          serializer = serializer_class.new(@model)
          resource_identifier = ResourceIdentifier.new(serializer)
          inflection = ActiveModelSerializers.config.jsonapi_resource_type
          type = @model.class.model_name.send(inflection)
          expected = {
            id: id,
            type: type
          }

          assert_equal(expected, resource_identifier.as_json)
        end
      end
    end
  end
end

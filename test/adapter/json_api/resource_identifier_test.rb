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

        def test_defined_type
          actual = actual_resource_identifier_object(WithDefinedTypeSerializer)
          expected = { id: expected_model_id, type: 'with-defined-type' }
          assert_equal actual, expected
        end

        def test_singular_type
          actual = with_jsonapi_inflection :singular do
            actual_resource_identifier_object(AuthorSerializer)
          end
          expected = { id: expected_model_id, type: 'author' }
          assert_equal actual, expected
        end

        def test_plural_type
          actual = with_jsonapi_inflection :plural do
            actual_resource_identifier_object(AuthorSerializer)
          end
          expected = { id: expected_model_id, type: 'authors' }
          assert_equal actual, expected
        end

        def test_type_with_namespace
          Object.const_set(:Admin, Module.new)
          model = Class.new(::Model)
          Admin.const_set(:PowerUser, model)
          serializer = Class.new(ActiveModel::Serializer)
          Admin.const_set(:PowerUserSerializer, serializer)
          with_namespace_separator '--' do
            admin_user = Admin::PowerUser.new
            serializer = Admin::PowerUserSerializer.new(admin_user)
            expected = {
              id: admin_user.id,
              type: 'admin--power-users'
            }

            identifier = ResourceIdentifier.new(serializer, {})
            actual = identifier.as_json
            assert_equal(expected, actual)
          end
        end

        def test_id_defined_on_object
          actual = actual_resource_identifier_object(AuthorSerializer)
          expected = { id: @model.id.to_s, type: expected_model_type }
          assert_equal actual, expected
        end

        def test_id_defined_on_serializer
          actual = actual_resource_identifier_object(WithDefinedIdSerializer)
          expected = { id: 'special_id', type: expected_model_type }
          assert_equal actual, expected
        end

        def test_id_defined_on_fragmented
          actual = actual_resource_identifier_object(FragmentedSerializer)
          expected = { id: 'special_id', type: expected_model_type }
          assert_equal actual, expected
        end

        private

        def actual_resource_identifier_object(serializer_class)
          serializer = serializer_class.new(@model)
          resource_identifier = ResourceIdentifier.new(serializer, nil)
          resource_identifier.as_json
        end

        def expected_model_type
          inflection = ActiveModelSerializers.config.jsonapi_resource_type
          @model.class.model_name.send(inflection)
        end

        def expected_model_id
          @model.id.to_s
        end
      end
    end
  end
end

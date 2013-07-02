require 'newbase/test_helper'
require 'newbase/active_model/serializer'

module ActiveModel
  class Serializer
    class AttributesTest < ActiveModel::TestCase
      class Model
        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
        attributes :attr1, :attr2
      end

      def setup
        model = Model.new({ :attr1 => 'value1', :attr2 => 'value2', :attr3 => 'value3' })
        @model_serializer = ModelSerializer.new(model)
      end

      def test_attributes_definition
        assert_equal(['attr1', 'attr2'],
                     @model_serializer.class._attributes)
      end

      def test_attributes_serialization_using_serializable_hash
        assert_equal({
          'attr1' => 'value1', 'attr2' => 'value2'
        }, @model_serializer.serializable_hash)
      end

      def test_attributes_serialization_using_as_json
        assert_equal({
          'attr1' => 'value1', 'attr2' => 'value2'
        }, @model_serializer.as_json)
      end
    end
  end
end

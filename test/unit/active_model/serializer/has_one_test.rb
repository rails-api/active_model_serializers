require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class Serializer
    class HasOneTest < ActiveModel::TestCase
      def setup
        @model = ::Model.new({ :attr1 => 'value1', :attr2 => 'value2', :attr3 => 'value3' })
        @model_serializer = AnotherSerializer.new(@model)
      end

      def test_associations_definition
        associations = @model_serializer.class._associations

        assert_equal 1, associations.length
        assert_kind_of Association::HasOne, associations[0]
        assert_equal 'model', associations[0].name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        @model_serializer.class._associations[0].embed = :ids
        assert_equal({
          'attr2' => 'value2', 'attr3' => 'value3', 'model_id' => @model.model.object_id
        }, @model_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        @model_serializer.class._associations[0].embed = :ids
        assert_equal({
          'attr2' => 'value2', 'attr3' => 'value3', 'model_id' => @model.model.object_id
        }, @model_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @model_serializer.class._associations[0].embed = :objects
        assert_equal({
          'attr2' => 'value2', 'attr3' => 'value3', 'model' => { 'attr1' => 'v1', 'attr2' => 'v2' }
        }, @model_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @model_serializer.class._associations[0].embed = :objects
        assert_equal({
          'attr2' => 'value2', 'attr3' => 'value3', 'model' => { 'attr1' => 'v1', 'attr2' => 'v2' }
        }, @model_serializer.as_json)
      end
    end
  end
end

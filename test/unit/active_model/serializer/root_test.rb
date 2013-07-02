require 'newbase/test_helper'
require 'newbase/active_model/serializer'

module ActiveModel
  class Serializer
    class RootAsOptionTest < ActiveModel::TestCase
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
      ModelSerializer.root = true

      def setup
        @model = Model.new({ :attr1 => 'value1', :attr2 => 'value2', :attr3 => 'value3' })
        @serializer = ModelSerializer.new(@model, root: 'initialize')
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal({
          'attr1' => 'value1', 'attr2' => 'value2'
        }, @serializer.serializable_hash)
      end

      def test_root_using_as_json
        assert_equal({
          'initialize' => {
            'attr1' => 'value1', 'attr2' => 'value2'
          }
        }, @serializer.as_json)
      end

      def test_root_from_serializer_name
        @serializer = ModelSerializer.new(@model)

        assert_equal({
          'model' => {
            'attr1' => 'value1', 'attr2' => 'value2'
          }
        }, @serializer.as_json)
      end

      def test_root_as_argument_takes_presedence
        assert_equal({
          'argument' => {
            'attr1' => 'value1', 'attr2' => 'value2'
          }
        }, @serializer.as_json(root: 'argument'))
      end
    end

    class RootInSerializerTest < ActiveModel::TestCase
      class Model
        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
        root :in_serializer
        attributes :attr1, :attr2
      end

      def setup
        model = Model.new({ :attr1 => 'value1', :attr2 => 'value2', :attr3 => 'value3' })
        @serializer = ModelSerializer.new(model)
        @rooted_serializer = ModelSerializer.new(model, root: :initialize)
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal({
          'attr1' => 'value1', 'attr2' => 'value2'
        }, @serializer.serializable_hash)
      end

      def test_root_using_as_json
        assert_equal({
          'in_serializer' => {
            'attr1' => 'value1', 'attr2' => 'value2'
          }
        }, @serializer.as_json)
      end

      def test_root_in_initializer_takes_precedence
        assert_equal({
          'initialize' => {
            'attr1' => 'value1', 'attr2' => 'value2'
          }
        }, @rooted_serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          'argument' => {
            'attr1' => 'value1', 'attr2' => 'value2'
          }
        }, @rooted_serializer.as_json(root: :argument))
      end
    end
  end
end

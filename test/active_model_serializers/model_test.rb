require 'test_helper'

module ActiveModelSerializers
  class ModelTest < ActiveSupport::TestCase
    include ActiveModel::Serializer::Lint::Tests

    setup do
      @resource = ActiveModelSerializers::Model.new
    end

    def test_initialization_with_string_keys
      klass = Class.new(ActiveModelSerializers::Model) do
        attributes :key
      end
      value = 'value'

      model_instance = klass.new('key' => value)

      assert_equal model_instance.read_attribute_for_serialization(:key), value
    end

    def test_attributes_can_be_read_for_serialization
      klass = Class.new(ActiveModelSerializers::Model) do
        attr_accessor :one, :two, :three
      end
      original_attributes = { one: 1, two: 2, three: 3 }
      instance = klass.new(original_attributes)

      # Initial value
      expected_attributes = { one: 1, two: 2, three: 3 }
      assert_equal expected_attributes, instance.attributes
      assert_equal 1, instance.one
      assert_equal 1, instance.read_attribute_for_serialization(:one)

      # Change via accessor
      instance.one = :not_one

      assert_equal :not_one, instance.one
      assert_equal :not_one, instance.read_attribute_for_serialization(:one)
    end

    def test_id_attribute_can_be_read_for_serialization
      klass = Class.new(ActiveModelSerializers::Model) do
        attr_accessor :id, :one, :two, :three
      end
      self.class.const_set(:SomeTestModel, klass)
      original_attributes = { id: :ego, one: 1, two: 2, three: 3 }
      instance = klass.new(original_attributes)

      # Initial value
      assert_equal 1, instance.one
      assert_equal 1, instance.read_attribute_for_serialization(:one)

      # Change via accessor
      instance.id = :superego

      assert_equal :superego, instance.id
      assert_equal :superego, instance.read_attribute_for_serialization(:id)
    ensure
      self.class.send(:remove_const, :SomeTestModel)
    end
  end
end

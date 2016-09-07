require 'test_helper'

module ActiveModelSerializers
  class ModelTest < ActiveSupport::TestCase
    include ActiveModel::Serializer::Lint::Tests

    def setup
      @resource = ActiveModelSerializers::Model.new

      @klass = Class.new(ActiveModelSerializers::Model) do
        attr_accessor :key

        def self.name
          'TestModel'
        end
      end
    end

    def test_initialization_with_string_keys
      model_instance = @klass.new('key' => 'value')

      assert_equal 'value', model_instance.read_attribute_for_serialization(:key)
    end

    def test_direct_accessor_assignment
      model_instance = @klass.new
      model_instance.key = 'value'
      assert_equal 'value', model_instance.read_attribute_for_serialization(:key)
    end

    def test_fetch_id_from_attributes
      model_instance = @klass.new(id: 1)
      assert_equal 1, model_instance.id
    end

    # Note: 'id' defined by attr_accessor
    # is mutually exclusive from default id behavior
    # IOW, defined attr_accessors 'win'
    def test_id_from_accessor
      @klass.class_eval do
        attr_accessor :id
      end
      model_instance = @klass.new
      model_instance.id = 1
      assert_equal 1, model_instance.id
    end

    # not needed, out superclass
    #def test_id_as_defined_method
      #@klass.class_eval do
        #def id
          #@id
        #end

        #def id=(val)
          #@id = val
        #end
      #end

      #model_instance = @klass.new
      #model_instance.id = 1
      #assert_equal 1, model_instance.id
    #end

    # Note: This does not work if @klass defines
    # attr_accessor :id
    def test_default_id
      model_instance = @klass.new
      assert_equal 'testmodel', model_instance.id
    end

    def test_errors
      model_instance = @klass.new
      model_instance.errors.add(:key, 'is blank')
      assert_equal true, model_instance.errors[:key].present?
    end
  end
end

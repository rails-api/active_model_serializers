require 'test_helper'

module ActiveModelSerializers
  class ModelTest < ActiveSupport::TestCase
    include ActiveModel::Serializer::Lint::Tests

    def setup
      @resource = ActiveModelSerializers::Model.new
    end

    def test_initialization_with_string_keys
      klass = Class.new(ActiveModelSerializers::Model) do
        attr_accessor :key
      end
      value = 'value'

      model_instance = klass.new('key' => value)

      assert_equal model_instance.read_attribute_for_serialization(:key), value
    end
  end
end

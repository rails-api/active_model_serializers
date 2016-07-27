require 'test_helper'

module ActiveModelSerializers
  class JsonPointerTest < ActiveSupport::TestCase
    test 'attribute_pointer' do
      attribute_name = 'title'
      pointer = ActiveModelSerializers::JsonPointer.new(:attribute, attribute_name)
      assert_equal '/data/attributes/title', pointer
    end

    test 'primary_data_pointer' do
      pointer = ActiveModelSerializers::JsonPointer.new(:primary_data)
      assert_equal '/data', pointer
    end

    test 'unkown_data_pointer' do
      assert_raises(TypeError) do
        ActiveModelSerializers::JsonPointer.new(:unknown)
      end
    end
  end
end

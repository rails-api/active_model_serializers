require 'test_helper'

module ActiveModel
  class DefaultSerializer
    class Test < Minitest::Test
      def test_serialize_objects
        assert_equal(nil, DefaultSerializer.new(nil).serializable_object)
        assert_equal(1, DefaultSerializer.new(1).serializable_object)
        assert_equal('hi', DefaultSerializer.new('hi').serializable_object)
      end
    end
  end
end

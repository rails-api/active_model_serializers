require 'test_helper'

module ActiveModel
  class DefaultSerializer
    class Test < ActiveModel::TestCase
      def test_serialize_objects
        assert_equal(nil, DefaultSerializer.new(nil).serializable_hash)
        assert_equal(1, DefaultSerializer.new(1).serializable_hash)
        assert_equal('hi', DefaultSerializer.new('hi').serializable_hash)
        obj = Struct.new(:a, :b).new(1, 2)
        assert_equal({ a: 1, b: 2 }, DefaultSerializer.new(obj).serializable_hash)
      end
    end
  end
end

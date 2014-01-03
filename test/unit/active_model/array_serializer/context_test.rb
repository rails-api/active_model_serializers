require 'test_helper'

module ActiveModel
  class ArraySerializer
    class ContextTest < ActiveModel::TestCase
      def test_context_using_a_hash
        serializer = ArraySerializer.new(nil, context: { a: 1, b: 2 })
        assert_equal(1, serializer.context[:a])
        assert_equal(2, serializer.context[:b])
      end

      def test_context_using_an_object
        serializer = ArraySerializer.new(nil, context: Struct.new(:a, :b).new(1, 2))
        assert_equal(1, serializer.context.a)
        assert_equal(2, serializer.context.b)
      end
    end
  end
end

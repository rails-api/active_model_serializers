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

    class ScopeTest < ActiveModel::TestCase
      def test_array_serializer_pass_context_to_item_serializers
        array = [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array, context: { scope: current_user })

        expected = [{ name: 'Name 1', description: 'Description 1 - user' },
                    { name: 'Name 2', description: 'Description 2 - user' }]

        assert_equal expected, serializer.serializable_array
      end

      private

      def current_user
        'user'
      end
    end
  end
end

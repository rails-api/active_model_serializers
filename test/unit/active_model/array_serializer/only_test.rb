require 'test_helper'

module ActiveModel
  class ArraySerializer
    class OnlyTest < Minitest::Test
      def test_array_serializer_pass_only_to_items_serializers
        array = [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array, only: [:name])

        expected = [{ name: 'Name 1' },
                    { name: 'Name 2' }]

        assert_equal expected, serializer.serializable_array
      end
    end
  end
end

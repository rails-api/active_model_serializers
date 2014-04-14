require 'test_helper'

module ActiveModel
  class ArraySerializer
    class KeyFormatTest < Minitest::Test
      def test_array_serializer_pass_options_to_items_serializers
        array = [WebLog.new({ name: 'Name 1', display_name: 'Display Name 1'}),
                 WebLog.new({ name: 'Name 2', display_name: 'Display Name 2'})]
        serializer = ArraySerializer.new(array, key_format: :lower_camel)

        expected = [{ name: 'Name 1', displayName: 'Display Name 1' },
                    { name: 'Name 2', displayName: 'Display Name 2' }]

        assert_equal expected, serializer.serializable_array
      end
    end
  end
end

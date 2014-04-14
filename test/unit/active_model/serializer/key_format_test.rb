require 'test_helper'

module ActiveModel
  class Serializer
    class KeyFormatTest < Minitest::Test
      def test_lower_camel_format_option
        object     = WebLog.new({ name: 'Name 1', display_name: 'Display Name 1'})
        serializer = WebLogSerializer.new(object, key_format: :lower_camel)

        expected = { name: 'Name 1', displayName: 'Display Name 1' }

        assert_equal expected, serializer.serializable_object
      end

      def test_lower_camel_format_serializer
        object     = WebLog.new({ name: 'Name 1', display_name: 'Display Name 1'})
        serializer = WebLogLowerCamelSerializer.new(object)

        expected = { name: 'Name 1', displayName: 'Display Name 1' }

        assert_equal expected, serializer.serializable_object
      end
    end
  end
end

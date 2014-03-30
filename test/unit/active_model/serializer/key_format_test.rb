require 'test_helper'

module ActiveModel
  class Serializer
    class KeyFormatTest < Minitest::Test
      def test_lower_camel_format_option
        object     = Blog.new({ name: 'Name 1', display_name: 'Display Name 1'})
        serializer = BlogSerializer.new(object, key_format: :lower_camel)

        expected = { name: 'Name 1', displayName: 'Display Name 1' }

        assert_equal expected, serializer.serializable_object
      end

      def test_lower_camel_format_serializer
        object     = Blog.new({ name: 'Name 1', display_name: 'Display Name 1'})
        serializer = BlogLowerCamelSerializer.new(object)

        expected = { name: 'Name 1', displayName: 'Display Name 1' }

        assert_equal expected, serializer.serializable_object
      end
    end
  end
end

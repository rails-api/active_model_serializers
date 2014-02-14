require 'test_helper'

module ActiveModel
  class Serializer
    class OptionsTest < Minitest::Test
      def setup
        @serializer = ProfileSerializer.new(nil, context: {foo: :bar})
      end

      def test_custom_options_are_accessible_from_serializer
        assert_equal({foo: :bar}, @serializer.context)
      end
    end
  end
end

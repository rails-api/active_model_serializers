require 'test_helper'

module ActiveModel
  class ArraySerializer
    class OptionsTest < Minitest::Test
      def test_custom_options_are_accessible_from_serializer

        array = [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array, only: [:name], context: {foo: :bar})

        assert_equal({foo: :bar}, serializer.context)
      end
    end
  end
end

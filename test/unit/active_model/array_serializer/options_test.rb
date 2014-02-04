require 'test_helper'

module ActiveModel
  class ArraySerializer
    class OptionsTest < Minitest::Test
      def setup
        @array = [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        @serializer = ArraySerializer.new(@array, scope: current_user)
      end

      def test_array_serializer_pass_options_to_items_serializers
        expected = [{ name: 'Name 1', description: 'Description 1 - user' },
                    { name: 'Name 2', description: 'Description 2 - user' }]

        assert_equal expected, @serializer.serializable_array
      end

      def test_array_serializer_injects_listing_option
        assert @serializer.serializer_for(Profile).listed?
      end

      private

      def current_user
        'user'
      end
    end
  end
end

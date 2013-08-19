require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class ArraySerializer
    class Test < ActiveModel::TestCase
      def setup
        array = [1, 2, 3]
        @serializer = ActiveModel::Serializer.serializer_for(array).new(array)
      end

      def test_serializer_for_array_returns_appropriate_type
        assert_kind_of ArraySerializer, @serializer
      end

      def test_array_serializer_serializes_simple_objects
        assert_equal [1, 2, 3], @serializer.serializable_array
      end

      def test_array_serializer_serializes_models
        array = [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array)

        expected = [{'name' => 'Name 1', 'description' => 'Description 1'},
                    {'name' => 'Name 2', 'description' => 'Description 2'}]

        assert_equal expected, serializer.serializable_array
      end

      def test_array_serializers_each_serializer
        array = [::Model.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 ::Model.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array, each_serializer: ProfileSerializer)

        expected = [{'name' => 'Name 1', 'description' => 'Description 1'},
                    {'name' => 'Name 2', 'description' => 'Description 2'}]

        assert_equal expected, serializer.serializable_array
      end
    end
  end
end

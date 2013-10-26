require 'test_helper'

module ActiveModel
  class HashSerializer
    class SerializeTest < ActiveModel::TestCase
      def setup
        hash = {one: 1, two: 2, three: 3}
        @serializer = ActiveModel::Serializer.serializer_for(hash).new(hash)
      end

      def test_serializer_for_hash_returns_appropriate_type
        assert_kind_of HashSerializer, @serializer
      end

      def test_hash_serializer_serializes_simple_objects
        assert_equal({one: 1, two: 2, three: 3}, @serializer.serializable_hash)
        assert_equal({one: 1, two: 2, three: 3}, @serializer.as_json)
      end

      def test_hash_serializer_serializes_models
        hash = {profile1: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                profile2: Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })}
        serializer = HashSerializer.new(hash)

        expected = {profile1: { name: 'Name 1', description: 'Description 1' },
                    profile2: { name: 'Name 2', description: 'Description 2' }}

        assert_equal expected, serializer.serializable_hash
        assert_equal expected, serializer.as_json
      end

      def test_hash_serializers_value_serializer
        hash = {model1: ::Model.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                model2: ::Model.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })}
        serializer = HashSerializer.new(hash, value_serializer: ProfileSerializer)

        expected = {model1: { name: 'Name 1', description: 'Description 1' },
                    model2: { name: 'Name 2', description: 'Description 2' }}

        assert_equal expected, serializer.serializable_hash
        assert_equal expected, serializer.as_json
      end
    end
  end
end

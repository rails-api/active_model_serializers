require 'test_helper'

module ActiveModel
  class HashSerializer
    class RootAsOptionTest < ActiveModel::TestCase
      def setup
        @old_root = HashSerializer._root
        @profile1 = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile2 = Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
        @serializer = HashSerializer.new({profile1: @profile1, profile2: @profile2}, root: :initialize)
      end

      def teardown
        HashSerializer._root = @old_root
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal({
          profile1: { name: 'Name 1', description: 'Description 1' },
          profile2: { name: 'Name 2', description: 'Description 2' }
        }, @serializer.serializable_hash)
      end

      def test_root_using_as_json
        assert_equal({
          initialize: {
            profile1: { name: 'Name 1', description: 'Description 1' },
            profile2: { name: 'Name 2', description: 'Description 2' }
          }
        }, @serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          argument: {
            profile1: { name: 'Name 1', description: 'Description 1' },
            profile2: { name: 'Name 2', description: 'Description 2' }
          }
        }, @serializer.as_json(root: :argument))
      end

      def test_using_false_root_in_initialize_takes_precedence
        HashSerializer._root = 'root'
        @serializer = HashSerializer.new({profile1: @profile1, profile2: @profile2}, root: false)

        assert_equal({
          profile1: { name: 'Name 1', description: 'Description 1' },
          profile2: { name: 'Name 2', description: 'Description 2' }
        }, @serializer.as_json)
      end
    end

    class RootInSerializerTest < ActiveModel::TestCase
      def setup
        @old_root = HashSerializer._root
        HashSerializer._root = :in_serializer
        @profile1 = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile2 = Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
        @serializer = HashSerializer.new({profile1: @profile1, profile2: @profile2})
        @rooted_serializer = HashSerializer.new({profile1: @profile1, profile2: @profile2}, root: :initialize)
      end

      def teardown
        HashSerializer._root = @old_root
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal({
          profile1: { name: 'Name 1', description: 'Description 1' },
          profile2: { name: 'Name 2', description: 'Description 2' }
        }, @serializer.serializable_hash)
      end

      def test_root_using_as_json
        assert_equal({
          in_serializer: {
            profile1: { name: 'Name 1', description: 'Description 1' },
            profile2: { name: 'Name 2', description: 'Description 2' }
          }
        }, @serializer.as_json)
      end

      def test_root_in_initializer_takes_precedence
        assert_equal({
          initialize: {
            profile1: { name: 'Name 1', description: 'Description 1' },
            profile2: { name: 'Name 2', description: 'Description 2' }
          }
        }, @rooted_serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          argument: {
            profile1: { name: 'Name 1', description: 'Description 1' },
            profile2: { name: 'Name 2', description: 'Description 2' }
          }
        }, @rooted_serializer.as_json(root: :argument))
      end
    end
  end
end

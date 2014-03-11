require 'test_helper'

module ActiveModel
  class ArraySerializer
    class RootAsOptionTest < Minitest::Test
      def setup
        @old_root = ArraySerializer._root
        @profile1 = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile2 = Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
        @serializer = ArraySerializer.new([@profile1, @profile2], root: :initialize)
      end

      def teardown
        ArraySerializer._root = @old_root
      end

      def test_root_is_not_displayed_using_serializable_array
        assert_equal([
          { name: 'Name 1', description: 'Description 1' },
          { name: 'Name 2', description: 'Description 2' }
        ], @serializer.serializable_array)
      end

      def test_root_using_as_json
        assert_equal({
          initialize: [
            { name: 'Name 1', description: 'Description 1' },
            { name: 'Name 2', description: 'Description 2' }
          ]
        }, @serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          argument: [
            { name: 'Name 1', description: 'Description 1' },
            { name: 'Name 2', description: 'Description 2' }
          ]
        }, @serializer.as_json(root: :argument))
      end

      def test_using_false_root_in_initialize_takes_precedence
        ArraySerializer._root = 'root'
        @serializer = ArraySerializer.new([@profile1, @profile2], root: false)

        assert_equal([
          { name: 'Name 1', description: 'Description 1' },
          { name: 'Name 2', description: 'Description 2' }
        ], @serializer.as_json)
      end
    end

    class RootInSerializerTest < Minitest::Test
      def setup
        @old_root = ArraySerializer._root
        ArraySerializer._root = :in_serializer
        @profile1 = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile2 = Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
        @serializer = ArraySerializer.new([@profile1, @profile2])
        @rooted_serializer = ArraySerializer.new([@profile1, @profile2], root: :initialize)
      end

      def teardown
        ArraySerializer._root = @old_root
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal([
          { name: 'Name 1', description: 'Description 1' },
          { name: 'Name 2', description: 'Description 2' }
        ], @serializer.serializable_array)
      end

      def test_root_using_as_json
        assert_equal({
          in_serializer: [
            { name: 'Name 1', description: 'Description 1' },
            { name: 'Name 2', description: 'Description 2' }
          ]
        }, @serializer.as_json)
      end

      def test_root_in_initializer_takes_precedence
        assert_equal({
          initialize: [
            { name: 'Name 1', description: 'Description 1' },
            { name: 'Name 2', description: 'Description 2' }
          ]
        }, @rooted_serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          argument: [
            { name: 'Name 1', description: 'Description 1' },
            { name: 'Name 2', description: 'Description 2' }
          ]
        }, @rooted_serializer.as_json(root: :argument))
      end
    end

    class DuplicateRootKeysTest < Minitest::Test
      def setup
        @catalog = Catalog.new({ name: 'Catalog root' })
        @serializer = ArraySerializer.new([@catalog], root: :catalogs)
      end

      def test_duplicate_root_keys_using_as_json
        assert_equal({
          catalogs: [
            { name: 'Catalog root', 'sub_catalog_ids' => @catalog.sub_catalogs.map(&:object_id) },
            { name: 'Catalog 1', 'sub_catalog_ids' => [] },
            { name: 'Catalog 2', 'sub_catalog_ids' => [] },
          ]
        }, @serializer.as_json)
      end
    end
  end
end

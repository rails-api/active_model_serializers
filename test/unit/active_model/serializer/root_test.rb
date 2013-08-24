require 'test_helper'

module ActiveModel
  class Serializer
    class RootAsOptionTest < ActiveModel::TestCase
      def setup
        @old_root = ProfileSerializer._root
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @serializer = ProfileSerializer.new(@profile, root: 'initialize')
        ProfileSerializer._root = true
      end

      def teardown
        ProfileSerializer._root = @old_root
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal({
          'name' => 'Name 1', 'description' => 'Description 1'
        }, @serializer.serializable_hash)
      end

      def test_root_using_as_json
        assert_equal({
          'initialize' => {
            'name' => 'Name 1', 'description' => 'Description 1'
          }
        }, @serializer.as_json)
      end

      def test_root_from_serializer_name
        @serializer = ProfileSerializer.new(@profile)

        assert_equal({
          'profile' => {
            'name' => 'Name 1', 'description' => 'Description 1'
          }
        }, @serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          'argument' => {
            'name' => 'Name 1', 'description' => 'Description 1'
          }
        }, @serializer.as_json(root: 'argument'))
      end
    end

    class RootInSerializerTest < ActiveModel::TestCase
      def setup
        @old_root = ProfileSerializer._root
        ProfileSerializer._root = 'in_serializer'
        profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @serializer = ProfileSerializer.new(profile)
        @rooted_serializer = ProfileSerializer.new(profile, root: :initialize)
      end

      def teardown
        ProfileSerializer._root = @old_root
      end

      def test_root_is_not_displayed_using_serializable_hash
        assert_equal({
          'name' => 'Name 1', 'description' => 'Description 1'
        }, @serializer.serializable_hash)
      end

      def test_root_using_as_json
        assert_equal({
          'in_serializer' => {
            'name' => 'Name 1', 'description' => 'Description 1'
          }
        }, @serializer.as_json)
      end

      def test_root_in_initializer_takes_precedence
        assert_equal({
          'initialize' => {
            'name' => 'Name 1', 'description' => 'Description 1'
          }
        }, @rooted_serializer.as_json)
      end

      def test_root_as_argument_takes_precedence
        assert_equal({
          'argument' => {
            'name' => 'Name 1', 'description' => 'Description 1'
          }
        }, @rooted_serializer.as_json(root: :argument))
      end
    end
  end
end

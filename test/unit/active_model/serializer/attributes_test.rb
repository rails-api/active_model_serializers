require 'test_helper'

module ActiveModel
  class Serializer
    class AttributesTest < ActiveModel::TestCase
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
      end

      def test_attributes_definition
        assert_equal(['name', 'description'],
                     @profile_serializer.class._attributes)
      end

      def test_attributes_serialization_using_serializable_hash
        assert_equal({
          'name' => 'Name 1', 'description' => 'Description 1'
        }, @profile_serializer.serializable_hash)
      end

      def test_attributes_serialization_using_as_json
        assert_equal({
          'name' => 'Name 1', 'description' => 'Description 1'
        }, @profile_serializer.as_json)
      end
    end
  end
end

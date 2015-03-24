require 'test_helper'

module ActiveModel
  class Serializer
    class AttributesTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
      end

      def test_attributes_definition
        assert_equal([:name, :description],
                     @profile_serializer.class._attributes)
      end

      def test_attributes_with_fields_option
        assert_equal({name: 'Name 1'},
                     @profile_serializer.attributes(fields: [:name]))
      end

      def test_required_fields
        assert_equal({name: 'Name 1', description: 'Description 1'},
                     @profile_serializer.attributes(fields: [:name, :description], required_fields: [:name]))

      end
    end
  end
end

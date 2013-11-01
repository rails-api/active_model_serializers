require 'test_helper'

module ActiveModel
  class Serializer
    class AttributesTest < ActiveModel::TestCase
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
      end

      def test_attributes_definition
        assert_equal([:name, :description],
                     @profile_serializer.class._attributes)
      end

      def test_attributes_serialization_using_serializable_hash
        assert_equal({
          name: 'Name 1', description: 'Description 1'
        }, @profile_serializer.serializable_hash)
      end

      def test_attributes_serialization_using_as_json
        assert_equal({
          'profile' => { name: 'Name 1', description: 'Description 1' }
        }, @profile_serializer.as_json)
      end
    end

    class HashKeyTest < ActiveModel::TestCase
      def setup
        @commenter = Commenter.new({ first_name: 'Steve', last_name: 'Jobs', company: 'Apple' })
        @commenter_serializer = CommenterSerializer.new(@commenter)
      end

      def test_attributes_serialization_using_camelcase_key_conversion
        @commenter_serializer.convert_type = 'camelcase'
        assert_equal({
          firstName: 'Steve', lastName: 'Jobs', company: 'Apple'
        }, @commenter_serializer.serializable_hash)
      end

      def test_attributes_serialization_using_upcase_key_conversion
        @commenter_serializer.convert_type = 'upcase'
        assert_equal({
          FIRST_NAME: 'Steve', LAST_NAME: 'Jobs', COMPANY: 'Apple'
        }, @commenter_serializer.serializable_hash)
      end
    end

    class HelpersTest < ActiveModel::TestCase
      def setup
        @commenter = Commenter.new({ first_name: 'Steve', last_name: 'Wozniak', company: 'Apple' })
        @commenter_serializer = CommenterSerializer.new(@commenter)
      end

      def test_attributes_serialization_using_camelize_keys_helper
        @commenter_serializer.camelize_keys!
        assert_equal("camelcase", @commenter_serializer.convert_type)
      end

      def test_attributes_serialization_using_upcase_keys_helper
        @commenter_serializer.upcase_keys!
        assert_equal("upcase", @commenter_serializer.convert_type)
      end
    end
  end
end

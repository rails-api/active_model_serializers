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

      def test_attributes_inheritance
        inherited_serializer_klass = Class.new(ProfileSerializer) do
          attributes :comments
        end
        another_inherited_serializer_klass = Class.new(ProfileSerializer)

        assert_equal([:name, :description, :comments],
                     inherited_serializer_klass._attributes)
        assert_equal([:name, :description],
                     another_inherited_serializer_klass._attributes)
      end

      def tests_query_attributes_strip_question_mark
        model = Class.new(::Model) do
          def strip?
            true
          end
        end

        serializer = Class.new(ActiveModel::Serializer) do
          attributes :strip?
        end

        actual = serializer.new(model.new).as_json

        assert_equal({ strip: true }, actual)
      end
    end
  end
end

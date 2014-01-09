require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationsTest < Minitest::Test
      def test_associations_inheritance
        inherited_serializer_klass = Class.new(PostSerializer) do
          has_many :users
        end
        another_inherited_serializer_klass = Class.new(PostSerializer)

        assert_equal([:comments, :users],
                     inherited_serializer_klass._associations.keys)
        assert_equal([:comments],
                     another_inherited_serializer_klass._associations.keys)
      end
    end
  end
end

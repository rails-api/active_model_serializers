require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationMacrosTest < Minitest::Test
      AuthorSummarySerialization = Class.new
      class AssociationsTestSerialization < ActiveModel::Serializer
        belongs_to :author, serializer: AuthorSummarySerialization
        has_many :comments
        has_one :category
      end

      def before_setup
        @reflections = AssociationsTestSerialization._reflections
      end

      def test_has_one_defines_reflection
        has_one_reflection = HasOneReflection.new(:category, {})

        assert_includes(@reflections, has_one_reflection)
      end

      def test_has_many_defines_reflection
        has_many_reflection = HasManyReflection.new(:comments, {})

        assert_includes(@reflections, has_many_reflection)
      end

      def test_belongs_to_defines_reflection
        belongs_to_reflection = BelongsToReflection.new(:author, serializer: AuthorSummarySerialization)

        assert_includes(@reflections, belongs_to_reflection)
      end
    end
  end
end

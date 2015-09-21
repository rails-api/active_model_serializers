require 'test_helper'

module ActiveModel
  class Serializer
    module Utils
      class NestedLookupPathsTest < Minitest::Test
        def test_activemodel_serializer
          expected = [::ActiveModel::Serializer, ::Object]
          actual = Utils.nested_lookup_paths(ActiveModel::Serializer)
          assert_equal(expected, actual)
        end

        def test_nested_classes
          expected = [::TweetSerializer::ShareSerializer::AuthorSerializer,
                      ::ShareSerializer::AuthorSerializer,
                      ::AuthorSerializer,
                      ::Object]
          actual = Utils.nested_lookup_paths(TweetSerializer::ShareSerializer::AuthorSerializer)
          assert_equal(expected, actual)
        end
      end
    end
  end
end

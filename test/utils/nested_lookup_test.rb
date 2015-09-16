require 'test_helper'

module ActiveModel
  class Serializer
    module Utils
      class NestedLookupTest < Minitest::Test
        def test_existing
          paths = [::TweetSerializer, ::Object]
          expected = ::TweetSerializer::ShareSerializer
          actual = Utils.nested_lookup(paths, 'ShareSerializer')
          assert_equal(expected, actual)
        end

        def test_non_existing
          paths = [::Object]
          actual = Utils.nested_lookup(paths, 'NonExistingSerializer')
          assert_nil(actual)
        end
      end
    end
  end
end

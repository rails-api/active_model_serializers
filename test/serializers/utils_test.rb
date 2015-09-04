module ActiveModel
  class Serializer
    module Utils
      class UtilsTest < MiniTest::Test
        def test_include_array_to_hash
          expected = {author: [], comments: {author: :bio}, posts: [:comments]}
          input = [:author, comments: {author: :bio}, posts: [:comments]]
          actual = ActiveModel::Serializer::Utils.include_array_to_hash(input)

          assert_equal(expected, actual)
        end

      end
    end
  end
end

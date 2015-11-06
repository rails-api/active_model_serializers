require 'test_helper'

module ActiveModel
  class Serializer
    class IncludeTree
      module Parsing
        class IncludeArgsToHashTest < MiniTest::Test
          def test_include_args_to_hash_from_symbol
            expected = { author: {} }
            input = :author
            actual = Parsing.include_args_to_hash(input)

            assert_equal(expected, actual)
          end

          def test_include_args_to_hash_from_array
            expected = { author: {}, comments: {} }
            input = [:author, :comments]
            actual = Parsing.include_args_to_hash(input)

            assert_equal(expected, actual)
          end

          def test_include_args_to_hash_from_nested_array
            expected = { author: {}, comments: { author: {} } }
            input = [:author, comments: [:author]]
            actual = Parsing.include_args_to_hash(input)

            assert_equal(expected, actual)
          end

          def test_include_args_to_hash_from_array_of_hashes
            expected = {
              author: {},
              blogs: { posts: { contributors: {} } },
              comments: { author: { blogs: { posts: {} } } }
            }
            input = [
              :author,
              blogs: [posts: :contributors],
              comments: { author: { blogs: :posts } }
            ]
            actual = Parsing.include_args_to_hash(input)

            assert_equal(expected, actual)
          end

          def test_array_of_string
            expected = {
              comments: { author: {}, attachment: {} }
            }
            input = [
              'comments.author',
              'comments.attachment'
            ]
            actual = Parsing.include_args_to_hash(input)

            assert_equal(expected, actual)
          end
        end
      end
    end
  end
end

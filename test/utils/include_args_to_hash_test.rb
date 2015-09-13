require 'test_helper'

module ActiveModel
  class Serializer
    module Utils
      class IncludeArgsToHashTest < Minitest::Test
        def test_nil
          input = nil
          expected = {}
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_empty_string
          input = ''
          expected = {}
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_single_string
          input = 'author'
          expected = { author: {} }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_multiple_strings
          input = 'author,comments'
          expected = { author: {}, comments: {} }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_multiple_strings_with_space
          input = 'author, comments'
          expected = { author: {}, comments: {} }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_nested_string
          input = 'posts.author'
          expected = { posts: { author: {} } }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_multiple_nested_string
          input = 'posts.author,posts.comments.author,comments'
          expected = { posts: { author: {}, comments: { author: {} } }, comments: {} }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_empty_array
          input = []
          expected = {}
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_simple_array
          input = [:comments, :author]
          expected = { author: {}, comments: {} }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end

        def test_nested_array
          input = [:comments, posts: [:author, comments: [:author]]]
          expected = { posts: { author: {}, comments: { author: {} } }, comments: {} }
          actual = ActiveModel::Serializer::Utils.include_args_to_hash(input)
          assert_equal(expected, actual)
        end
      end
    end
  end
end

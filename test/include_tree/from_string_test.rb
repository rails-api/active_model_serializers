require 'test_helper'

module ActiveModel
  class Serializer
    class IncludeTree
      class FromStringTest < ActiveSupport::TestCase
        def test_single_string
          input = 'author'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:author))
        end

        def test_multiple_strings
          input = 'author,comments'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:author))
          assert(actual.key?(:comments))
        end

        def test_multiple_strings_with_space
          input = 'author, comments'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:author))
          assert(actual.key?(:comments))
        end

        def test_nested_string
          input = 'posts.author'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:author))
        end

        def test_multiple_nested_string
          input = 'posts.author,posts.comments.author,comments'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:author))
          assert(actual[:posts].key?(:comments))
          assert(actual[:posts][:comments].key?(:author))
          assert(actual.key?(:comments))
        end

        def test_toplevel_star_string
          input = '*'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:comments))
        end

        def test_nested_star_string
          input = 'posts.*'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:comments))
        end

        def test_nested_star_middle_string
          input = 'posts.*.author'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:comments))
          assert(actual[:posts][:comments].key?(:author))
          refute(actual[:posts][:comments].key?(:unspecified))
        end

        def test_nested_star_lower_precedence_string
          input = 'posts.comments.author,posts.*'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:comments))
          assert(actual[:posts][:comments].key?(:author))
        end

        def test_toplevel_double_star_string
          input = '**'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:comments))
          assert(actual[:posts][:comments].key?(:posts))
        end

        def test_nested_double_star_string
          input = 'comments, posts.**'
          actual = ActiveModel::Serializer::IncludeTree.from_string(input)
          assert(actual.key?(:comments))
          refute(actual[:comments].key?(:author))
          assert(actual.key?(:posts))
          assert(actual[:posts].key?(:comments))
          assert(actual[:posts][:comments].key?(:posts))
        end
      end
    end
  end
end

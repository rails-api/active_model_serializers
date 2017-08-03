# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class InflectorTest < Test
      def test_underscore_leaves_alone_word_without_caps_dash_nor_double_dot
        assert_equal "active_model/errors", Inflector.underscore("active_model/errors")
      end

      def test_underscore_converts_dash_to_underscore
        assert_equal "active_model_errors", Inflector.underscore("active_model-errors")
      end

      def test_underscore_coerces_non_string_to_string
        assert_equal "active_model/errors", Inflector.underscore(:"active_model::errors")
      end

      def test_underscore_downcases_upcase_letters
        assert_equal "active_model", Inflector.underscore("ACTIVE_MODEL")
      end

      def test_underscore_separates_upcase_letters_ending_in_a_number_from_following_upcase_letter_followed_by_downcase_letter_by_an_underscore
        assert_equal "api1_api", Inflector.underscore("API1API")
      end

      def test_underscore_separates_camel_case_words_by_underscore
        assert_equal "active_model", Inflector.underscore("ActiveModel")
      end

      def test_underscore_converts_double_dot_to_forward_slash
        assert_equal "active_model/errors", Inflector.underscore("ActiveModel::Errors")
      end

      def test_underscore_does_not_mutate_the_original_string
        original_string = "ActiveModel"
        original_string_id = original_string.object_id
        assert_equal "active_model", Inflector.underscore(original_string)
        assert_equal "ActiveModel", original_string
        assert_equal original_string_id, original_string.object_id
      end

      def test_pluralize_adds_s_to_word_not_ending_in_s
        assert_equal "dogs", Inflector.pluralize("dog")
      end

      def test_pluralize_adds_es_to_word_ending_in_s
        assert_equal "dresses", Inflector.pluralize("dress")
      end

      def test_singularize_removes_es_from_word_ending_in_es
        assert_equal "beach", Inflector.singularize("beaches")
      end

      def test_singularize_removes_s_from_word_ending_in_s
        assert_equal "day", Inflector.singularize("days")
      end

      def test_singularize_leaves_alone_word_not_ending_in_s
        assert_equal "fish", Inflector.singularize("fish")
      end
    end
  end
end

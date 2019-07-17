# frozen_string_literal: true

require 'test_helper'

module ActiveModel
  class Serializer
    class FieldsetTest < ActiveSupport::TestCase
      def setup
        @fieldset = ActiveModel::Serializer::Fieldset.new('post' => %w(id title), 'comment' => ['body'])
      end

      def test_fieldset_with_hash
        expected = { post: [:id, :title], comment: [:body] }

        assert_equal(expected, @fieldset.fields)
      end

      def test_fields_for_accepts_string_or_symbol
        expected = [:id, :title]

        assert_equal(expected, @fieldset.fields_for(:post))
        assert_equal(expected, @fieldset.fields_for('post'))
      end
    end
  end
end

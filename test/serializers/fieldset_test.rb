require 'test_helper'

module ActiveModel
  class Serializer
    class FieldsetTest < ActiveSupport::TestCase
      test 'fieldset_with_hash' do
        fieldset = ActiveModel::Serializer::Fieldset.new('post' => %w(id title), 'comment' => ['body'])
        expected = { post: [:id, :title], comment: [:body] }

        assert_equal(expected, fieldset.fields)
      end
    end
  end
end

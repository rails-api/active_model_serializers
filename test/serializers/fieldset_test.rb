require 'test_helper'

module ActiveModel
  class Serializer
    class FieldsetTest < Minitest::Test

      def test_fieldset_with_hash
        fieldset = ActiveModel::Serializer::Fieldset.new({'post' => ['id', 'title'], 'coment' => ['body']})

        assert_equal(
          {:post=>[:id, :title], :coment=>[:body]}, 
          fieldset.fields
        )
      end

      def test_fieldset_with_array_of_fields_and_root_name
        fieldset = ActiveModel::Serializer::Fieldset.new(['title'], 'post')

        assert_equal(
          {:post => [:title]}, 
          fieldset.fields
        )
      end
    end
  end
end
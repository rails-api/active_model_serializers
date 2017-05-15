# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class AttributesTest < Test
      class ParentModelSerializer < Serializer
        attribute :name
        attribute :description, key: :summary
      end

      def setup
        super
        @object = ParentModel.new(
          id: 1,
          name: "name",
          description: "description"
        )
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_instance_attributes
        expected_attributes = {
          name: "name",
          summary: "description"
        }
        assert_equal expected_attributes, @serializer_instance.attributes
      end
    end
  end
end

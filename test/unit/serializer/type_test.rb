# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class TypeTest < Test
      class ParentModelSerializer < Serializer
        type :something
      end

      def setup
        super
        @object = ParentModel.new(id: 1,)
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_instance_type
        expected_type = :something
        assert_equal expected_type, @serializer_instance.type
      end
    end
  end
end

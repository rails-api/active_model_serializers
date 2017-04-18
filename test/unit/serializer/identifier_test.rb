# frozen_string_literal: true
require 'test_helper'

module AMS
  class Serializer
    class IdentifierTest < Test
      class ParentModelSerializer < Serializer
        id_field :id
      end

      def setup
        super
        @object = ParentModel.new( id: 1,)
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_instance_id
        expected_id = 1
        assert_equal expected_id, @serializer_instance.id
      end
    end
  end
end

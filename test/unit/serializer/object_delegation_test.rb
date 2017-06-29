# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class ObjectDelegationTest < Test
      class ParentModelSerializer < Serializer
      end

      def setup
        super
        @object = ParentModel.new(id: 1)
        class << @object
          def delegated?
            true
          end
        end
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_delegates_method_to_object
        assert @serializer_instance.delegated?
      end

      def test_model_delegates_respond_to_object
        refute @serializer_instance.respond_to?(:not_delegated?)
      end
    end
  end
end

# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class ObjectDelegationTest < Test
      class ParentModelSerializer < Serializer
        attribute :some_method
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

      def test_model_delegates_respond_to_missing_to_object
        refute @serializer_instance.respond_to?(:not_delegated?)
      end

      def test_serializer_binds_method_method
        file, = @serializer_instance.method(:some_method).source_location
        assert_match(%r{/lib/ams/serializer.rb\z}, file)
      end

      def test_serializer_instance_raises_method_missing
        exception = assert_raises(NameError) do
          @serializer_instance.non_existent_method
        end
        assert_match(%r{undefined method `non_existent_method' for #<ParentModel:[^@]+@id=1>\z}, exception.message)
      end

      def test_serializer_object_raises_method_missing
        exception = assert_raises(NameError) do
          @serializer_instance.method(:non_existent_method)
        end
        assert_match(%r{undefined method `non_existent_method' for class `AMS::Serializer::ObjectDelegationTest::ParentModelSerializer'\z}, exception.message)
      end
    end
  end
end

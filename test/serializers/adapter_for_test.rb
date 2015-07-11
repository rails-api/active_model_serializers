module ActiveModel
  class Serializer
    class OverriddenAdapterSerializer < ActiveModel::Serializer
      use_adapter :json
    end

    class AdapterForTest < Minitest::Test
      def setup
        @previous_adapter = ActiveModel::Serializer.config.adapter
      end

      def teardown
        ActiveModel::Serializer.config.adapter = @previous_adapter
      end

      def test_returns_default_adapter
        adapter = ActiveModel::Serializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::FlattenJson, adapter
      end

      def test_overwrite_adapter_with_symbol
        ActiveModel::Serializer.config.adapter = :null

        adapter = ActiveModel::Serializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::Null, adapter
      ensure

      end

      def test_overwrite_adapter_with_class
        ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::Null

        adapter = ActiveModel::Serializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::Null, adapter
      end

      def test_adapter_specified_in_serializer
        ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::Null

        adapter = OverriddenAdapterSerializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::Json, adapter
      end

      def test_raises_exception_if_invalid_symbol_given
        ActiveModel::Serializer.config.adapter = :unknown

        assert_raises ArgumentError do
          ActiveModel::Serializer.adapter
        end
      end

      def test_raises_exception_if_it_does_not_know_hot_to_infer_adapter
        ActiveModel::Serializer.config.adapter = 42

        assert_raises ArgumentError do
          ActiveModel::Serializer.adapter
        end
      end
    end
  end
end

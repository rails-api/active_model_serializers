require 'test_helper'

module ActiveModel
  class Serializer
    class AdapterTest < Minitest::Test
      def setup
        profile = Profile.new
        serializer = ProfileSerializer.new(profile)
        @adapter = ActiveModel::Serializer::Adapter.new(serializer)
      end

      def test_serializable_hash_is_abstract_method
        assert_raises(NotImplementedError) do
          @adapter.serializable_hash(only: [:name])
        end
      end

      def test_to_json_is_abstract_method
        assert_raises(NotImplementedError) do
          @adapter.to_json(only: [:name])
        end
      end
    end

    class AdapterForTest < Minitest::Test
      def setup
        profile = Profile.new
        @serializer = ProfileSerializer.new(profile)
        @previous_adapter = ActiveModel::Serializer.config.adapter
      end

      def teardown
        ActiveModel::Serializer.config.adapter = @previous_adapter
      end

      def test_returns_default_adapter
        adapter = Adapter.adapter_for(@serializer)
        assert_kind_of ActiveModel::Serializer::Adapter::SimpleAdapter, adapter
      end

      def test_overwrite_adapter_with_symbol
        ActiveModel::Serializer.config.adapter = :null

        adapter = Adapter.adapter_for(@serializer)
        assert_kind_of ActiveModel::Serializer::Adapter::NullAdapter, adapter
      ensure

      end

      def test_overwrite_adapter_with_class
        ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::NullAdapter

        adapter = Adapter.adapter_for(@serializer)
        assert_kind_of ActiveModel::Serializer::Adapter::NullAdapter, adapter
      end

      def test_raises_exception_if_invalid_symbol_given
        ActiveModel::Serializer.config.adapter = :unknown

        assert_raises ArgumentError do
          Adapter.adapter_for(@serializer)
        end
      end

      def test_raises_exception_if_it_does_not_know_hot_to_infer_adapter
        ActiveModel::Serializer.config.adapter = 42

        assert_raises ArgumentError do
          Adapter.adapter_for(@serializer)
        end
      end
    end
  end
end

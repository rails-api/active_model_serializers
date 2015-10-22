require 'test_helper'

module ActiveModel
  class Serializer
    class ConfigurationTest < Minitest::Test
      def test_collection_serializer
        assert_equal ActiveModel::Serializer::CollectionSerializer, ActiveModel::Serializer.config.collection_serializer
      end

      def test_array_serializer
        assert_equal ActiveModel::Serializer::CollectionSerializer, ActiveModel::Serializer.config.array_serializer
      end

      def test_setting_array_serializer_sets_collection_serializer
        config = ActiveModel::Serializer.config
        old_config = config.dup
        begin
          assert_equal ActiveModel::Serializer::CollectionSerializer, config.collection_serializer
          config.array_serializer = :foo
          assert_equal config.array_serializer, :foo
          assert_equal config.collection_serializer, :foo
        ensure
          ActiveModel::Serializer.config.replace(old_config)
        end
      end

      def test_default_adapter
        assert_equal :attributes, ActiveModel::Serializer.config.adapter
      end
    end
  end
end

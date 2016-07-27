require 'test_helper'

module ActiveModel
  class Serializer
    class ConfigurationTest < ActiveSupport::TestCase
      test 'collection_serializer' do
        assert_equal ActiveModel::Serializer::CollectionSerializer, ActiveModelSerializers.config.collection_serializer
      end

      test 'array_serializer' do
        assert_equal ActiveModel::Serializer::CollectionSerializer, ActiveModelSerializers.config.array_serializer
      end

      test 'setting_array_serializer_sets_collection_serializer' do
        config = ActiveModelSerializers.config
        old_config = config.dup
        begin
          assert_equal ActiveModel::Serializer::CollectionSerializer, config.collection_serializer
          config.array_serializer = :foo
          assert_equal config.array_serializer, :foo
          assert_equal config.collection_serializer, :foo
        ensure
          ActiveModelSerializers.config.replace(old_config)
        end
      end

      test 'default_adapter' do
        assert_equal :attributes, ActiveModelSerializers.config.adapter
      end
    end
  end
end

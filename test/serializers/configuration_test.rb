require 'test_helper'

module ActiveModel
  class Serializer
    class ConfigurationTest < Minitest::Test
      def test_array_serializer
        assert_equal ActiveModel::Serializer::ArraySerializer, ActiveModel::Serializer.config.array_serializer
      end

      def test_default_adapter
        assert_equal :flatten_json, ActiveModel::Serializer.config.adapter
      end

      def test_default_sideload_associations
        assert_equal false, ActiveModel::Serializer.config.sideload_associations
      end

    end
  end
end

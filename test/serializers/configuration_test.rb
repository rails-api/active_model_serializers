require 'test_helper'

module ActiveModel
  class Serializer
    class ConfigurationTest < Minitest::Test
      def test_array_serializer
        assert_equal ActiveModel::Serializer::ArraySerializer, ActiveModel::Serializer.config.array_serializer
      end

      def test_default_adapter
        assert_equal :json, ActiveModel::Serializer.config.adapter
      end
    end
  end
end

require 'test_helper'

module ActiveModel
  class Serializer
    class RootTest < Minitest::Test
      VirtualValue = Class.new(::Model)

      class VirtualValueSerializer < ActiveModel::Serializer
        attributes :id
      end

      def setup
        @virtual_value = VirtualValue.new(id: 1)
      end

      def test_overwrite_root
        serializer = VirtualValueSerializer.new(@virtual_value, root: 'smth')
        assert_equal('smth', serializer.json_key)
      end

      def test_underscore_in_root
        serializer = VirtualValueSerializer.new(@virtual_value)

        namespace_path = self.class.to_s.underscore
        assert_equal("#{namespace_path}/virtual_value", serializer.json_key)
      end
    end
  end
end

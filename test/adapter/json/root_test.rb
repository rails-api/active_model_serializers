require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class Json
        class RootTest < Minitest::Test
          def setup
            @virtual_value = VirtualValue.new(id: 1)
          end

          def test_overwrite_root
            serializer = VirtualValueSerializer.new(@virtual_value)
            adapter = Json.new(serializer, root: 'smth')
            assert_equal(:smth, adapter.send(:root))
          end

          def test_underscore_in_root
            serializer = VirtualValueSerializer.new(@virtual_value)
            adapter = Json.new(serializer)
            assert_equal(:virtual_value, adapter.send(:root))
          end
        end
      end
    end
  end
end

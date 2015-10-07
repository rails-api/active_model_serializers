require 'test_helper'
require_relative 'collection_serializer_test'

module ActiveModel
  class Serializer
    class ArraySerializerTest < CollectionSerializerTest
      extend ActiveSupport::Testing::Stream
      def self.run_one_method(*)
        stderr = (capture(:stderr) do
          super
        end)
        if stderr !~ /Calling deprecated ArraySerializer/
          fail Minitest::Assertion, stderr
        end
      end

      def collection_serializer
        ArraySerializer
      end
    end
  end
end

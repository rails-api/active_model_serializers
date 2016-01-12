require 'test_helper'
require_relative 'collection_serializer_test'

module ActiveModel
  class Serializer
    # Minitest.run_one_method isn't present in minitest 4
    if $minitest_version > 4 # rubocop:disable Style/GlobalVars
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
    else
      class ArraySerializerTest < ActiveSupport::TestCase
        extend ActiveSupport::Testing::Stream
        def test_json_key_with_root_warns_when_using_array_serializer
          stderr = (capture(:stderr) do
            comment = Comment.new
            post = Post.new
            serializer = ArraySerializer.new([comment, post])
            assert_equal 'comments', serializer.json_key
          end)
          assert_match(/Calling deprecated ArraySerializer/, stderr)
        end
      end
    end
  end
end

require 'test_helper'

module ActiveModel
  class Serializer
    class AdapterTest < Minitest::Test
      def setup
        profile = Profile.new
        @serializer = ProfileSerializer.new(profile)
        @adapter = ActiveModel::Serializer::Adapter.new(@serializer)
      end

      def test_serializable_hash_is_abstract_method
        assert_raises(NotImplementedError) do
          @adapter.serializable_hash(only: [:name])
        end
      end

      def test_serializer
        assert_equal @serializer, @adapter.serializer
      end
    end
  end
end

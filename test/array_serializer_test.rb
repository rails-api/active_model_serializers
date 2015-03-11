require 'test_helper'

module ActiveModel
  class Serializer
    class ArraySerializerTest < Minitest::Test
      def setup
        @comment = Comment.new
        @post = Post.new
        @serializer = ArraySerializer.new([@comment, @post], {some: :options})
      end

      def test_respond_to_each
        assert_respond_to @serializer, :each
      end

      def test_each_object_should_be_serialized_with_appropriate_serializer
        serializers =  @serializer.to_a

        assert_kind_of CommentSerializer, serializers.first
        assert_kind_of Comment, serializers.first.object

        assert_kind_of PostSerializer, serializers.last
        assert_kind_of Post, serializers.last.object

        assert_equal serializers.last.custom_options[:some], :options
      end
    end
  end
end

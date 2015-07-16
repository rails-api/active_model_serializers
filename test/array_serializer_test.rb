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

      def test_serializer_option_not_passed_to_each_serializer
        serializers = ArraySerializer.new([@post], {serializer: PostSerializer}).to_a

        refute serializers.first.custom_options.key?(:serializer)
      end

      def test_serializer_option_string_value
        serializers = ArraySerializer.new([@post], {serializer: "PostSerializer"}).to_a

        assert_kind_of PostSerializer, serializers.last
        assert_kind_of Post, serializers.last.object
      end

      def test_meta_and_meta_key_attr_readers
        meta_content = {meta: "the meta", meta_key: "the meta key"}
        @serializer = ArraySerializer.new([@comment, @post], meta_content)

        assert_equal @serializer.meta, "the meta"
        assert_equal @serializer.meta_key, "the meta key"
      end

      def test_json_key_when_resource_is_empty
        Array.class_eval do
          def name
            'PostComment'
          end
        end
        @post_comments = []
        @serializer = ArraySerializer.new(@post_comments)
        assert_equal @serializer.json_key, "post_comments"
      end
    end
  end
end

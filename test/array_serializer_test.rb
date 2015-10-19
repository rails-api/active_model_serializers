require 'test_helper'

module ActiveModel
  class Serializer
    class ArraySerializerTest < Minitest::Test
      def setup
        @comment = Comment.new
        @post = Post.new
        @resource = build_named_collection @comment, @post
        @serializer = ArraySerializer.new(@resource, { some: :options })
      end

      def build_named_collection(*resource)
        resource.define_singleton_method(:name) { 'MeResource' }
        resource
      end

      def test_has_object_reader_serializer_interface
        assert_equal @serializer.object, @resource
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
        serializers = ArraySerializer.new([@post], { serializer: PostSerializer }).to_a

        refute serializers.first.custom_options.key?(:serializer)
      end
    end
  end
end

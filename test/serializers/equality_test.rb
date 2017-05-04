require 'test_helper'

module ActiveModel
  class Serializer
    class EqualityTest < ActiveSupport::TestCase
      class DummySerializer < ActiveModel::Serializer; end
      def setup
        comment_1 = Comment.new(id: 1)
        comment_2 = Comment.new(id: 2)

        @comment_serializer = CommentSerializer.new(comment_1)
        @comment_serializer_copy = CommentSerializer.new(comment_1)
        @another_comment_serializer = CommentSerializer.new(comment_2)
      end

      def test_equal
        assert_equal @comment_serializer, @comment_serializer_copy
      end

      def test_not_equal
        assert_not_equal @comment_serializer, @another_comment_serializer
      end
    end
  end
end

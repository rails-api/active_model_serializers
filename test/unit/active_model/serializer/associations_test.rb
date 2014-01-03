require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationsTest < ActiveModel::TestCase
      def test_associations_inheritance
        inherited_serializer_klass = Class.new(PostSerializer) do
          has_many :users
        end
        another_inherited_serializer_klass = Class.new(PostSerializer)

        assert_equal([:comments, :users],
                     inherited_serializer_klass._associations.keys)
        assert_equal([:comments],
                     another_inherited_serializer_klass._associations.keys)
      end
    end

    class AssociationsWithCustomSerializer < ActiveModel::TestCase
      def setup
        @post = Post.new(title: 'Hi', description: 'How are you?',
                         comments: [Comment.new(content: 'C1')])
      end

      def test_does_not_pass_custom_serializer_option_to_nested_associations
        post_serializer = Class.new(PostSerializer) do
          has_many :comments, serializer: CommentSerializer
        end
        serializer = post_serializer.new(@post)
        comment = serializer.associations[:comments].first

        assert_equal({content:'C1'}, comment)
      end
    end
  end
end

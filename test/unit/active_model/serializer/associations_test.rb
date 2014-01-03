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
        post = Post.new(title: 'Hi', description: 'How are you?', comments: [Comment.new])
        @category = Category.new(name: 'Hello, World!', posts: [post])
      end

      def test_does_not_pass_custom_serializer_option_to_nested_associations
        category_serializer = Class.new(CategorySerializer) do
          has_many :posts, serializer: PostSerializer
        end
        serializer = category_serializer.new(@category)
        comments = serializer.associations[:posts].first[:comments]

        assert_equal([{content:'C1'}, {content:'C2'}], comments)
      end
    end
  end
end

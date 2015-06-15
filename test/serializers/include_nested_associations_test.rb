require 'test_helper'

module ActiveModel
  class Serializer
    class IncludeNestedAssociationsTest < Minitest::Test
      def setup
        @author = Author.new(name: 'Steve K.')
        @author.bio = Bio.new(content: 'Hello!', rating: 5)

        @post = Post.new({ title: 'New Post', body: 'Body' })

        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]

        @post.author = @author
      end

      def test_no_nested_association_are_included_by_default
        @post_serializer = PostSerializer.new(@post)
        json = ActiveModel::Serializer::Adapter::Json.new(@post_serializer).as_json
        assert_nil json[:author][:bio]
      end

      def test_no_option_is_passed_in
        @post_serializer = PostSerializerWithNestedAssociations.new(@post)
        json = ActiveModel::Serializer::Adapter::Json.new(@post_serializer).as_json
        assert json[:author][:bio] != nil
      end
    end
  end
end

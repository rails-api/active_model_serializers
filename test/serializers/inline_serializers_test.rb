module ActiveModel
  class Serializer
    class InlineSerializersTest < Minitest::Test
      class PostSerializer < ActiveModel::Serializer
        attributes :title, :body
        belongs_to :author
        has_many :comments do
          attributes :body
          belongs_to :author
        end
      end

      def test_inline_serializer_defined_if_block_given
        refute_nil("#{self.class}::PostSerializer::CommentSerializer".safe_constantize)
        assert_equal(ActiveModel::Serializer, PostSerializer::CommentSerializer.superclass)
        assert_equal([:author], PostSerializer::CommentSerializer._reflections.map(&:name))
        assert_equal([:body], PostSerializer::CommentSerializer._attributes)
      end

      def test_inline_serializer_not_defined_unless_block_given
        assert_nil("#{self.class}::PostSerializer::AuthorSerializer".safe_constantize)
      end
    end
  end
end

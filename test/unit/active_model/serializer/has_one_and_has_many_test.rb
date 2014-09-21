require 'test_helper'

module ActiveModel
  class Serializer
    class HasOneAndHasManyTest < Minitest::Test
      def setup
        @post = SpecialPost.new({ title: 'T1', body: 'B1'})
        @post_serializer = SpecialPostSerializer.new(@post)
      end

      def teardown
      end

      def test_side_load_has_one_and_has_many_in_same_array
        assert_equal({
          "post" => {
            title: 'T1',
            body: 'B1',
            'comment_ids' => @post.comments.map { |c| c.object_id },
            'special_comment_id' => @post_serializer.special_comment.object_id,
          },
          "comments" => [{ content: 'C1' }, { content: 'C2' }, { content: 'special' }]
        }, @post_serializer.as_json(root: 'post'))
      end
    end
  end
end

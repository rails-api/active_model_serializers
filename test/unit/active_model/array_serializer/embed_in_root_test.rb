require 'test_helper'

module ActiveModel
  class ArraySerializer
    class EmbedInRootTest < ActiveModel::TestCase
      def setup
        @association = PostSerializer._associations[:comments]
        @old_association = @association.dup

        @post1 = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post2 = Post.new({ title: 'Title 2', body: 'Body 2', date: '1/1/2000' })

        @post2.comments = [
          Comment.new(content: 'C3'),
          Comment.new(content: 'C4')
        ]

        @serializer = ArraySerializer.new([@post1, @post2], root: :posts)
      end

      def teardown
        PostSerializer._associations[:comments] = @old_association
      end

      def test_associated_objects_of_multiple_instances_embedded_in_root
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
            posts: [
              {title: "Title 1", body: "Body 1", "comment_ids" => @post1.comments.map(&:object_id) },
              {title: "Title 2", body: "Body 2", "comment_ids" => @post2.comments.map(&:object_id) }
            ],
            comments: [
              {content: "C1"},
              {content: "C2"},
              {content: "C3"},
              {content: "C4"}
            ]
          }, @serializer.as_json)
      end

    end
  end
end

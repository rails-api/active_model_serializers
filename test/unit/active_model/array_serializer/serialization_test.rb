require 'test_helper'

module ActiveModel
  class ArraySerializer
    class BasicObjectsSerializationTest < ActiveModel::TestCase
      def setup
        array = [1, 2, 3]
        @serializer = ActiveModel::Serializer.serializer_for(array).new(array)
      end

      def test_serializer_for_array_returns_appropriate_type
        assert_kind_of ArraySerializer, @serializer
      end

      def test_array_serializer_serializes_simple_objects
        assert_equal [1, 2, 3], @serializer.serializable_array
        assert_equal [1, 2, 3], @serializer.as_json
      end
    end

    class ModelSerializationTest < ActiveModel::TestCase
      def test_array_serializer_serializes_models
        array = [Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array)

        expected = [{ name: 'Name 1', description: 'Description 1' },
                    { name: 'Name 2', description: 'Description 2' }]

        assert_equal expected, serializer.serializable_array
        assert_equal expected, serializer.as_json
      end

      def test_array_serializers_each_serializer
        array = [::Model.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                 ::Model.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })]
        serializer = ArraySerializer.new(array, each_serializer: ProfileSerializer)

        expected = [{ name: 'Name 1', description: 'Description 1' },
                    { name: 'Name 2', description: 'Description 2' }]

        assert_equal expected, serializer.serializable_array
        assert_equal expected, serializer.as_json
      end

      def test_associated_objects_of_multiple_instances_embedded_in_root
        @association = PostSerializer._associations[:comments]
        @old_association = @association.dup

        @association.embed = :ids
        @association.embed_in_root = true

        @post1 = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post2 = Post.new({ title: 'Title 2', body: 'Body 2', date: '1/1/2000' })

        @post2.comments = [
          Comment.new(content: 'C3'),
          Comment.new(content: 'C4')
        ]

        @serializer = ArraySerializer.new([@post1, @post2], root: :posts)
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
      ensure
        PostSerializer._associations[:comments] = @old_association
      end
    end
  end
end

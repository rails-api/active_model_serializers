require 'test_helper'

module ActiveModel
  class ArraySerializer
    class BasicObjectsSerializationTest < Minitest::Test
      def setup
        array = [1, 2, 3]
        @serializer = Serializer.serializer_for(array).new(array)
      end

      def test_serializer_for_array_returns_appropriate_type
        assert_kind_of ArraySerializer, @serializer
      end

      def test_array_serializer_serializes_simple_objects
        assert_equal [1, 2, 3], @serializer.serializable_array
        assert_equal [1, 2, 3], @serializer.as_json
      end
    end

    class ModelSerializationTest < Minitest::Test
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

        class << @post2
          attr_writer :comments
        end

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

      def test_associated_objects_of_recursive_instances_embedded_in_root
        CommentSerializer.has_many :comments
        @association = CommentSerializer._associations[:comments]

        @association.embed = :ids
        @association.embed_in_root = true

        @comment1 = Comment.new(content: 'C1')
        @comment2 = Comment.new(content: 'C2')

        class << @comment1
          attr_writer :comments
        end
        @comment1.comments = [Comment.new(content: 'C1-1')]

        @serializer = ArraySerializer.new([@comment1, @comment2], root: :comments)
        assert_equal({
          comments: [
            { content: 'C1', 'comment_ids' => @comment1.comments.map(&:object_id) },
            { content: 'C2', 'comment_ids' => [] },
            { content: 'C1-1', 'comment_ids' => []}
          ]
        }, @serializer.as_json)
      ensure
        CommentSerializer._associations = {}
      end

      def test_embed_object_for_has_one_association_with_nil_value
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup

        @association.embed = :objects

        @user1 = User.new({ name: 'User 1', email: 'email1@server.com' })
        @user2 = User.new({ name: 'User 2', email: 'email2@server.com' })

        class << @user1
          def profile
            nil
          end
        end

        class << @user2
          def profile
            @profile ||= Profile.new(name: 'Name 1', description: 'Desc 1')
          end
        end

        @serializer = ArraySerializer.new([@user1, @user2]) #, root: :posts)
        assert_equal([
          { name: "User 1", email: "email1@server.com", profile: nil },
          { name: "User 2", email: "email2@server.com", profile: { name: 'Name 1', description: 'Desc 1' } }
        ], @serializer.as_json)
      ensure
        UserSerializer._associations[:profile] = @old_association
      end

      def test_embed_object_in_root_for_has_one_association_with_nil_value
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup

        @association.embed = :ids
        @association.embed_in_root = true

        @user1 = User.new({ name: 'User 1', email: 'email1@server.com' })
        @user2 = User.new({ name: 'User 2', email: 'email2@server.com' })

        class << @user1
          def profile
            nil
          end
        end

        class << @user2
          def profile
            @profile ||= Profile.new(name: 'Name 1', description: 'Desc 1')
          end
        end

        @serializer = ArraySerializer.new([@user1, @user2], root: :users)
        assert_equal({
            users: [
              { name: "User 1", email: "email1@server.com", 'profile_id' => nil },
              { name: "User 2", email: "email2@server.com", 'profile_id' => @user2.profile.object_id }
            ],
            'profiles' => [
              { name: 'Name 1', description: 'Desc 1' }
            ]
          }, @serializer.as_json)
      ensure
        UserSerializer._associations[:profile] = @old_association
      end

      def test_embed_object_in_root_for_has_one_association_with_all_nil_values
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup

        @association.embed = :ids
        @association.embed_in_root = true

        @user1 = User.new({ name: 'User 1', email: 'email1@server.com' })
        @user2 = User.new({ name: 'User 2', email: 'email2@server.com' })

        class << @user1
          def profile
            nil
          end
        end

        class << @user2
          def profile
            nil
          end
        end

        @serializer = ArraySerializer.new([@user1, @user2], root: :users)
        assert_equal({
            users: [
              { name: "User 1", email: "email1@server.com", 'profile_id' => nil },
              { name: "User 2", email: "email2@server.com", 'profile_id' => nil }
            ]
          }, @serializer.as_json)
      ensure
        UserSerializer._associations[:profile] = @old_association
      end
    end
  end
end

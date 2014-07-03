require 'test_helper'

module ActiveModel
  class Serializer
    class EmbedInRootTest < Minitest::Test
      def setup
        @old_post_associations = PostSerializer._associations.dup
        @old_comment_associations = CommentSerializer._associations.dup
        @old_user_associations = UserSerializer._associations.dup

        # reset associations
        PostSerializer._associations = {}
        UserSerializer._associations = {}

        # set associations
        PostSerializer.has_one :user, embed: :ids, embed_in_root: true
        PostSerializer.has_many :comments, embed: :ids, embed_in_root: true
        CommentSerializer.has_one :user, embed: :ids, embed_in_root: true

        @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post_serializer = PostSerializer.new(@post)
      end

      def teardown
        PostSerializer._associations = @old_post_associations
        CommentSerializer._associations = @old_comment_associations
        UserSerializer._associations = @old_user_associations
      end

      def test_associations_embedding_ids_including_objects_with_same_key_serialization_using_as_json
        @user1 = User.new(name: 'post author')
        @user2 = User.new(name: 'comment author')

        @post.instance_variable_set(:@user, @user1)
        @post.comments.first.instance_variable_set(:@user, @user2)

        assert_equal({
          'post' => {
            title: 'Title 1',
            body: 'Body 1',
            'user_id' => @user1.object_id,
            'comment_ids' => @post.comments.map(&:object_id)
          },
          'users' => [
            { name: 'post author', email: nil },
            { name: 'comment author', email: nil }
          ],
          comments: [
            { content: 'C1', 'user_id' => @user2.object_id },
            { content: 'C2', 'user_id' => nil }
          ]
        }, @post_serializer.as_json)
      end
    end
  end
end

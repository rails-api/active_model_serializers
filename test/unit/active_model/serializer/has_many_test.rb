require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class Serializer
    class HasManyTest < ActiveModel::TestCase
      def setup
        @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post_serializer = PostSerializer.new(@post)
        @post_serializer.class._associations[0].include = false
        @post_serializer.class._associations[0].embed = :ids
      end

      def test_associations_definition
        associations = @post_serializer.class._associations

        assert_equal 1, associations.length
        assert_kind_of Association::HasMany, associations[0]
        assert_equal 'comments', associations[0].name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @post_serializer.class._associations[0].embed = :objects
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @post_serializer.class._associations[0].embed = :objects
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @post_serializer.class._associations[0].include = true
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }, 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @post_serializer.class._associations[0].include = true
        assert_equal({
          'title' => 'Title 1', 'body' => 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }, 'comments' => [{ 'content' => 'C1' }, { 'content' => 'C2' }]
        }, @post_serializer.as_json)
      end
    end
  end
end

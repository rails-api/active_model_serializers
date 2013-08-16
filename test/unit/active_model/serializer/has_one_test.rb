require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class Serializer
    class HasOneTest < ActiveModel::TestCase
      def setup
        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user)
        @user_serializer.class._associations[0].include = false
        @user_serializer.class._associations[0].embed = :ids
      end

      def test_associations_definition
        associations = @user_serializer.class._associations

        assert_equal 1, associations.length
        assert_kind_of Association::HasOne, associations[0]
        assert_equal 'profile', associations[0].name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @user_serializer.class._associations[0].embed = :objects
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile' => { 'name' => 'N1', 'description' => 'D1' }
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @user_serializer.class._associations[0].embed = :objects
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile' => { 'name' => 'N1', 'description' => 'D1' }
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @user_serializer.class._associations[0].include = true
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id, 'profile' => { 'name' => 'N1', 'description' => 'D1' }
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @user_serializer.class._associations[0].include = true
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id, 'profile' => { 'name' => 'N1', 'description' => 'D1' }
        }, @user_serializer.as_json)
      end
    end
  end
end

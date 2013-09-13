require 'test_helper'

module ActiveModel
  class Serializer
    class HasOneTest < ActiveModel::TestCase
      def setup
        @association = UserSerializer._associations[0]
        @old_association = @association.dup
        @association.embed = :ids
        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user)
      end

      def teardown
        UserSerializer._associations[0] = @old_association
      end

      def test_associations_definition
        assert_equal 1, UserSerializer._associations.length
        assert_kind_of Association::HasOne, @association
        assert_equal 'profile', @association.name
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

      def test_associations_embedding_ids_serialization_using_serializable_hash_and_key_from_options
        @association.key = 'key'
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'key' => @user.profile.object_id
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @association.embed = :objects
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profiles' => [{ 'name' => 'N1', 'description' => 'D1' }]
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @association.embed = :objects
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profiles' => [{ 'name' => 'N1', 'description' => 'D1' }]
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_nil_objects_serialization_using_as_json
        @association.embed = :objects
        @user.instance_eval do
          def profile
            nil
          end
        end

        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profiles' => [nil]
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash_and_root_from_options
        @association.embed = :objects
        @association.embedded_key = 'root'
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'root' => [{ 'name' => 'N1', 'description' => 'D1' }]
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @association.embed_in_root = true
        @user_serializer.root = nil
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.embed_in_root = true
        @user_serializer.root = nil
        assert_equal({
          'user' => { 'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id },
          'profiles' => [{ 'name' => 'N1', 'description' => 'D1' }]
        }, @user_serializer.as_json)
      end

      def test_associations_using_a_given_serializer
        @association.embed_in_root = true
        @user_serializer.root = nil
        @association.serializer_class = Class.new(ActiveModel::Serializer) do
          def name
            'fake'
          end

          attributes :name
        end

        assert_equal({
          'user' => { 'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id },
          'profiles' => [{ 'name' => 'fake' }]
        }, @user_serializer.as_json)
      end
    end
  end
end

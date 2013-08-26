require 'test_helper'

module ActiveModel
  class Serializer
    class HasOneTest < ActiveModel::TestCase
      def setup
        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user)
        @association = UserSerializer._associations[0]
        @association.include = false
        @association.embed = :ids
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

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @association.include = true
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id, 'profiles' => [{ 'name' => 'N1', 'description' => 'D1' }]
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.include = true
        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id, 'profiles' => [{ 'name' => 'N1', 'description' => 'D1' }]
        }, @user_serializer.as_json)
      end

      def test_associations_using_a_given_serializer
        @old_serializer = @association.serializer_class
        @association.include = true
        @association.serializer_class = Class.new(ActiveModel::Serializer) do
          def name
            'fake'
          end

          attributes :name
        end

        assert_equal({
          'name' => 'Name 1', 'email' => 'mail@server.com', 'profile_id' => @user.profile.object_id, 'profiles' => [{ 'name' => 'fake' }]
        }, @user_serializer.as_json)
      ensure
        @association.serializer_class = @old_serializer
      end
    end
  end
end

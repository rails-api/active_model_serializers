require 'test_helper'

module ActiveModel
  class Serializer
    class HasOneTest < ActiveModel::TestCase
      def setup
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup

        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user)
      end

      def teardown
        UserSerializer._associations[:profile] = @old_association
      end

      def test_associations_definition
        assert_equal 1, UserSerializer._associations.length
        assert_kind_of Association::HasOne, @association
        assert_equal 'profile', @association.name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        @association.embed = :ids

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', 'profile_id' => @user.profile.object_id
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        @association.embed = :ids

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', 'profile_id' => @user.profile.object_id }
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash_and_key_from_options
        @association.embed = :ids
        @association.key = 'key'

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', 'key' => @user.profile.object_id
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @association.embed = :objects

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', profile: { name: 'N1', description: 'D1' }
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @association.embed = :objects

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', profile: { name: 'N1', description: 'D1' } }
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_nil_ids_serialization_using_as_json
        @association.embed = :ids
        @user.instance_eval do
          def profile
            nil
          end
        end

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', 'profile_id' => nil }
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
          'user' => { name: 'Name 1', email: 'mail@server.com', profile: nil }
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash_and_root_from_options
        @association.embed = :objects
        @association.embedded_key = 'root'

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', 'root' => { name: 'N1', description: 'D1' }
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', 'profile_id' => @user.profile.object_id
        }, @user_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', 'profile_id' => @user.profile.object_id },
          'profiles' => [{ name: 'N1', description: 'D1' }]
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_ids_using_a_given_serializer
        @association.embed = :ids
        @association.embed_in_root = true
        @association.serializer_class = Class.new(ActiveModel::Serializer) do
          def name
            'fake'
          end

          attributes :name
        end

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', 'profile_id' => @user.profile.object_id },
          'profiles' => [{ name: 'fake' }]
        }, @user_serializer.as_json)
      end

      def test_associations_embedding_in_root_does_not_polute_association
        @association.embed_in_root = true

        serializer_class = @association.serializer_class

        @user_serializer.embedded_in_root_associations

        assert_equal(@association.serializer_class, serializer_class)
      end

      def test_associations_embedding_objects_using_a_given_serializer
        @association.serializer_class = Class.new(ActiveModel::Serializer) do
          def name
            'fake'
          end

          attributes :name
        end

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', profile: { name: 'fake' } }
        }, @user_serializer.as_json)
      end
    end
  end
end

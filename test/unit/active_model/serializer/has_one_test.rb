require 'test_helper'

module ActiveModel
  class Serializer
    class HasOneTest < Minitest::Test
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

      def test_associations_embedding_nil_ids_including_objects_serialization_using_as_json
        @association.embed = :ids
        @association.embed_in_root = true
        @user.instance_eval do
          def profile
            nil
          end
        end

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', 'profile_id' => nil },
          'profiles' => []
        }, @user_serializer.as_json)
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
        @association.serializer_from_options = Class.new(Serializer) do
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

      def test_associations_embedding_objects_using_a_given_serializer
        @association.serializer_from_options = Class.new(Serializer) do
          def name
            'fake'
          end

          attributes :name
        end

        assert_equal({
          'user' => { name: 'Name 1', email: 'mail@server.com', profile: { name: 'fake' } }
        }, @user_serializer.as_json)
      end

      def test_association_context_passed_as_option
        association = Association::HasOne.new('profile')
        serializer = @user_serializer.build_serializer(association)

        assert_equal(serializer.context, @user_serializer)
      end
    end
  end
end

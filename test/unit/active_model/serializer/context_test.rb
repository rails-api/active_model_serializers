require 'test_helper'

module ActiveModel
  class Serializer
    class ContextTest < ActiveModel::TestCase
      def test_context_using_a_hash
        serializer = UserSerializer.new(nil, context: { a: 1, b: 2 })
        assert_equal(1, serializer.context[:a])
        assert_equal(2, serializer.context[:b])
      end

      def test_context_using_an_object
        serializer = UserSerializer.new(nil, context: Struct.new(:a, :b).new(1, 2))
        assert_equal(1, serializer.context.a)
        assert_equal(2, serializer.context.b)
      end
    end

    class ContextAssociationTest < ActiveModel::TestCase
      def setup
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup
        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user, context: { admin: true })
      end

      def teardown
        UserSerializer._associations[:profile] = @old_association
      end

      def test_context_passed_through
        @association.serializer_class = Class.new(ActiveModel::Serializer) do
          def name
            context[:admin] ? 'Admin' : 'User'
          end

          attributes :name
        end

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', profile: { name: 'Admin' }
        }, @user_serializer.serializable_hash)
      end
    end
  end
end

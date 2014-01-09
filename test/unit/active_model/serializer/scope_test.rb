require 'test_helper'

module ActiveModel
  class Serializer
    class ScopeTest < Minitest::Test
      def setup
        @serializer = ProfileSerializer.new(nil, scope: current_user)
      end

      def test_scope
        assert_equal('user', @serializer.scope)
      end

      private

      def current_user
        'user'
      end
    end

    class NestedScopeTest < Minitest::Test
      def setup
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup
        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user, scope: 'user')
      end

      def teardown
        UserSerializer._associations[:profile] = @old_association
      end

      def test_scope_passed_through
        @association.serializer_from_options = Class.new(Serializer) do
          def name
            scope
          end

          attributes :name
        end

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', profile: { name: 'user' }
        }, @user_serializer.serializable_hash)
      end
    end

  end
end

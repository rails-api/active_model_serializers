require 'test_helper'

module ActiveModel
  class Serializer
    class ScopeTest < ActiveModel::TestCase
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
    
    class NestedScopeTest < ActiveModel::TestCase
      def setup
        @association = UserSerializer._associations[:profile]
        @old_association = @association.dup
        @user = User.new({ name: 'Name 1', email: 'mail@server.com', gender: 'M' })
        @user_serializer = UserSerializer.new(@user, scope: current_user)
      end

      def teardown
        UserSerializer._associations[:profile] = @old_association
      end

      def test_scope_passed_through
        @association.embed = :objects

        assert_equal({
          name: 'Name 1', email: 'mail@server.com', profile: { name: 'N1', description: 'D1 - user' }
        }, @user_serializer.serializable_hash)
      end


      private

      def current_user
        'user'
      end
    end
  end
end

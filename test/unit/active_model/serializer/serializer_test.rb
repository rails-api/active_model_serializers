require 'test_helper'

module ActiveModel
  class Serializer
    class SerializerForTest < Minitest::Test
      def setup
        @user = User.new({ name: 'User 1', email: 'email1@server.com' })
        @author = Author.new({ name: 'User 1', email: 'email1@server.com' })
      end

      def test_without_custom_serializer
        assert_equal(UserSerializer, ActiveModel::Serializer.serializer_for(@user))
      end

      def test_with_custom_serializer
        assert_equal(UserSerializer, ActiveModel::Serializer.serializer_for(@author))
      end
    end
  end
end

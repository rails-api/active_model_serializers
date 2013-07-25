require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class Serializer
    class ScopeTest < ActiveModel::TestCase
      def setup
        @serializer = ModelSerializer.new(nil, scope: current_user)
      end

      def test_scope
        assert_equal('user', @serializer.scope)
      end

      private

      def current_user
        'user'
      end
    end
  end
end

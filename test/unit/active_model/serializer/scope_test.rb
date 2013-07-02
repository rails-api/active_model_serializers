require 'newbase/test_helper'
require 'newbase/active_model/serializer'

module ActiveModel
  class Serializer
    class ScopeTest < ActiveModel::TestCase
      class Model
        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
      end

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

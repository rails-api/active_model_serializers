require 'test_helper'
require 'active_model/serializer_support'

module ActiveModel
  module SerializerSupport
    class Test < ActiveModel::TestCase
      def test_active_model_on_poro_returns_its_serializer
        assert_equal ModelSerializer, ::Model.new.active_model_serializer
      end
    end
  end
end

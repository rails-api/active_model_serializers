require 'newbase/test_helper'
require 'newbase/fixtures/active_record'
require 'newbase/active_model/serializer_support'

module ActiveModel
  module SerializerSupport
    class Test < ActiveModel::TestCase
      def test_active_model_returns_its_serializer
        assert_equal ARModelSerializer, ARModel.new.active_model_serializer
      end
    end
  end
end

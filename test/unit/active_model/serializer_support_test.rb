require 'newbase/test_helper'
require 'newbase/active_model/serializer_support'

module ActiveModel
  module SerializerSupport
    class Test < ActiveModel::TestCase
      class Model
        include ActiveModel::SerializerSupport
      end

      class ModelSerializer < ActiveModel::Serializer
      end

      def test_active_model_returns_its_serializer
        assert_equal ModelSerializer, Model.new.active_model_serializer
      end
    end
  end
end

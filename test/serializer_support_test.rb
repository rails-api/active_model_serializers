require "test_helper"

class RandomModel
  include ActiveModel::SerializerSupport
end

class SerializerSupportTest < ActiveModel::TestCase
  test "it returns nil if no serializer exists" do
    assert_equal nil, RandomModel.new.active_model_serializer
  end
end
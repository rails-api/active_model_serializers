require "test_helper"

class RandomModel
  include ActiveModel::SerializerSupport
end

class RandomModelCollection
  include ActiveModel::ArraySerializerSupport
end

module ActiveRecord
  class Relation
  end
end

class SerializerSupportTest < ActiveModel::TestCase
  test "it returns nil if no serializer exists" do
    assert_equal nil, RandomModel.new.active_model_serializer
  end

  test "it returns ArraySerializer for a collection" do
    assert_equal ActiveModel::ArraySerializer, RandomModelCollection.new.active_model_serializer
  end

  test "it automatically includes array_serializer in active_record/relation" do
    ActiveSupport.run_load_hooks(:active_record)
    assert_equal ActiveModel::ArraySerializer, ActiveRecord::Relation.new.active_model_serializer
  end
end


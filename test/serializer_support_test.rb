require "test_helper"

class RandomModel
  include ActiveModel::SerializerSupport
end

class RandomModelCollection
  include ActiveModel::ArraySerializerSupport
end

module ActiveRecord
  class Base
  end
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

  test "it automatically includes serializer support in active_record/base" do
    ActiveSupport.run_load_hooks(:active_record)
    assert ActiveRecord::Base.new.respond_to?(:active_model_serializer)
  end

  test "it automatically includes serializer support in action_controller/base" do
    ActiveSupport.run_load_hooks(:action_controller)
    assert ActionController::Base.new.respond_to?(:serialization_scope)
  end
end


require 'test_helper'

module ActiveRecord
  class RelationSerializationTest < ActiveSupport::TestCase
    def test_relation_serializer_when_no_serializer_class
      serializer = ActiveModel::Serializer.serializer_for(ARModels::Post.all)
      assert_equal serializer, ActiveModelSerializers.config.collection_serializer
    end

    def test_relation_serializer_when_has_serializer_class
      serializer = ActiveModel::Serializer.serializer_for(ARModels::Post::Special.all)
      assert_equal serializer, ActiveModelSerializers.config.collection_serializer
    end
  end
end

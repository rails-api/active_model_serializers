require 'test_helper'

module ActiveModel
  class SerializableResourceTest < Minitest::Test
    def setup
      @resource = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
      @serializer = ProfileSerialization.new(@resource)
      @adapter = ActiveModel::Serializer::Adapter.create(@serializer)
      @serializable_resource = ActiveModel::SerializableResource.new(@resource)
    end

    def test_serializable_resource_delegates_serializable_hash_to_the_adapter
      options = nil
      assert_equal @adapter.serializable_hash(options), @serializable_resource.serializable_hash(options)
    end

    def test_serializable_resource_delegates_to_json_to_the_adapter
      options = nil
      assert_equal @adapter.to_json(options), @serializable_resource.to_json(options)
    end

    def test_serializable_resource_delegates_as_json_to_the_adapter
      options = nil
      assert_equal @adapter.as_json(options), @serializable_resource.as_json(options)
    end
  end
end

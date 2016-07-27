require 'test_helper'

module ActiveModelSerializers
  class SerializableResourceTest < ActiveSupport::TestCase
    def setup
      @resource = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
      @serializer = ProfileSerializer.new(@resource)
      @adapter = ActiveModelSerializers::Adapter.create(@serializer)
      @serializable_resource = SerializableResource.new(@resource)
    end

    test 'deprecation' do
      assert_output(nil, /deprecated/) do
        deprecated_serializable_resource = ActiveModel::SerializableResource.new(@resource)
        assert_equal(@serializable_resource.as_json, deprecated_serializable_resource.as_json)
      end
    end

    test 'serializable_resource_delegates_serializable_hash_to_the_adapter' do
      options = nil
      assert_equal @adapter.serializable_hash(options), @serializable_resource.serializable_hash(options)
    end

    test 'serializable_resource_delegates_to_json_to_the_adapter' do
      options = nil
      assert_equal @adapter.to_json(options), @serializable_resource.to_json(options)
    end

    test 'serializable_resource_delegates_as_json_to_the_adapter' do
      options = nil
      assert_equal @adapter.as_json(options), @serializable_resource.as_json(options)
    end

    test 'use_adapter_with_adapter_option' do
      assert SerializableResource.new(@resource, adapter: 'json').use_adapter?
    end

    test 'use_adapter_with_adapter_option_as_false' do
      refute SerializableResource.new(@resource, adapter: false).use_adapter?
    end

    class SerializableResourceErrorsTest < Minitest::Test
      test 'serializable_resource_with_errors' do
        options = nil
        resource = ModelWithErrors.new
        resource.errors.add(:name, 'must be awesome')
        serializable_resource = ActiveModelSerializers::SerializableResource.new(
          resource,             serializer: ActiveModel::Serializer::ErrorSerializer,
                                adapter: :json_api
        )
        expected_response_document = {
          errors: [
            { source: { pointer: '/data/attributes/name' }, detail: 'must be awesome' }
          ]
        }
        assert_equal serializable_resource.as_json(options), expected_response_document
      end

      test 'serializable_resource_with_collection_containing_errors' do
        options = nil
        resources = []
        resources << resource = ModelWithErrors.new
        resource.errors.add(:title, 'must be amazing')
        resources << ModelWithErrors.new
        serializable_resource = SerializableResource.new(
          resources, serializer: ActiveModel::Serializer::ErrorsSerializer,
                     each_serializer: ActiveModel::Serializer::ErrorSerializer,
                     adapter: :json_api
        )
        expected_response_document = {
          errors: [
            { source: { pointer: '/data/attributes/title' }, detail: 'must be amazing' }
          ]
        }
        assert_equal serializable_resource.as_json(options), expected_response_document
      end
    end
  end
end

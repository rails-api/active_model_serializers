require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class ErrorsTest < Minitest::Test
        include ActiveModel::Serializer::Lint::Tests

        def setup
          @resource = ModelWithErrors.new
        end

        def test_active_model_with_error
          options = {
              serializer: ActiveModel::Serializer::ErrorSerializer,
              adapter: :'json_api/error'
          }

          @resource.errors.add(:name, 'cannot be nil')

          serializable_resource = ActiveModel::SerializableResource.new(@resource, options)
          assert_equal serializable_resource.serializer_instance.attributes, {}
          assert_equal serializable_resource.serializer_instance.object, @resource

          expected_errors_object =
            { 'errors'.freeze =>
              [
                {
                  source: { pointer: '/data/attributes/name' },
                  detail: 'cannot be nil'
                }
              ]
          }
          assert_equal serializable_resource.as_json, expected_errors_object
        end

        def test_active_model_with_multiple_errors
          options = {
              serializer: ActiveModel::Serializer::ErrorSerializer,
              adapter: :'json_api/error'
          }

          @resource.errors.add(:name, 'cannot be nil')
          @resource.errors.add(:name, 'must be longer')
          @resource.errors.add(:id, 'must be a uuid')

          serializable_resource = ActiveModel::SerializableResource.new(@resource, options)
          assert_equal serializable_resource.serializer_instance.attributes, {}
          assert_equal serializable_resource.serializer_instance.object, @resource

          expected_errors_object =
            { 'errors'.freeze =>
              [
                { :source => { :pointer => '/data/attributes/name' }, :detail => 'cannot be nil' },
                { :source => { :pointer => '/data/attributes/name' }, :detail => 'must be longer' },
                { :source => { :pointer => '/data/attributes/id' }, :detail => 'must be a uuid' }
              ]
          }
          assert_equal serializable_resource.as_json, expected_errors_object
        end
      end
    end
  end
end

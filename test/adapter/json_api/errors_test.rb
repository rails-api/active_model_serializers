require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class ErrorsTest < ActiveSupport::TestCase
        include ActiveModel::Serializer::Lint::Tests

        def setup
          @resource = ModelWithErrors.new
        end

        test 'active model with error' do
          options = {
            serializer: ActiveModel::Serializer::ErrorSerializer,
            adapter: :json_api
          }

          @resource.errors.add(:name, 'cannot be nil')

          serializable_resource = ActiveModelSerializers::SerializableResource.new(@resource, options)
          assert_equal serializable_resource.serializer_instance.attributes, {}
          assert_equal serializable_resource.serializer_instance.object, @resource

          expected_errors_object = {
            errors: [
              {
                source: { pointer: '/data/attributes/name' },
                detail: 'cannot be nil'
              }
            ]
          }
          assert_equal serializable_resource.as_json, expected_errors_object
        end

        test 'active_model_with_multiple_errors' do
          options = {
            serializer: ActiveModel::Serializer::ErrorSerializer,
            adapter: :json_api
          }

          @resource.errors.add(:name, 'cannot be nil')
          @resource.errors.add(:name, 'must be longer')
          @resource.errors.add(:id, 'must be a uuid')

          serializable_resource = ActiveModelSerializers::SerializableResource.new(@resource, options)
          assert_equal serializable_resource.serializer_instance.attributes, {}
          assert_equal serializable_resource.serializer_instance.object, @resource

          expected_errors_object = {
            errors: [
              { source: { pointer: '/data/attributes/name' }, detail: 'cannot be nil' },
              { source: { pointer: '/data/attributes/name' }, detail: 'must be longer' },
              { source: { pointer: '/data/attributes/id' }, detail: 'must be a uuid' }
            ]
          }
          assert_equal serializable_resource.as_json, expected_errors_object
        end

        # see http://jsonapi.org/examples/
        test 'parameter_source_type_error' do
          parameter = 'auther'
          error_source = ActiveModelSerializers::Adapter::JsonApi::Error.error_source(:parameter, parameter)
          assert_equal({ parameter: parameter }, error_source)
        end

        test 'unknown_source_type_error' do
          value = 'auther'
          assert_raises(ActiveModelSerializers::Adapter::JsonApi::Error::UnknownSourceTypeError) do
            ActiveModelSerializers::Adapter::JsonApi::Error.error_source(:hyper, value)
          end
        end
      end
    end
  end
end

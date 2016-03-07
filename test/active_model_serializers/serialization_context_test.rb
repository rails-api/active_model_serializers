require 'test_helper'

module ActiveModelSerializers
  class SerializationContextTest < ActionController::TestCase
    def test_create_context_with_request_url_and_query_parameters
      context = ActiveModelSerializers::SerializationContext.new(controller: self)

      assert_equal('http://test.host', context.request_url)
      assert_equal({}, context.query_parameters)
      assert_equal('ActiveModelSerializers', context.controller_namespace)
    end
  end
end

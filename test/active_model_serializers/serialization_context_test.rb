require 'test_helper'

class ActiveModelSerializers::SerializationContextTest < ActiveSupport::TestCase
  def create_context
    request = Minitest::Mock.new
    request.expect(:original_url, 'original_url')
    request.expect(:query_parameters, 'query_parameters')

    ActiveModelSerializers::SerializationContext.new(request)
  end

  def test_create_context_with_request_url_and_query_parameters
    context = create_context

    assert_equal context.request_url, 'original_url'
    assert_equal context.query_parameters, 'query_parameters'
  end
end

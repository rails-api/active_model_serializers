require 'support/isolated_unit'
require 'minitest/mock'
require 'action_dispatch'
require 'action_controller'

class JsonApiRendererTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::Isolation

  class TestController < ActionController::Base
    class << self
      attr_accessor :last_request_parameters
    end

    def render_with_jsonapi_renderer
      author = Author.new(params[:data][:attributes])
      render jsonapi: author
    end

    def parse
      self.class.last_request_parameters = request.request_parameters
      head :ok
    end
  end

  def teardown
    TestController.last_request_parameters = nil
  end

  def assert_parses(expected, actual, headers = {})
    post '/parse', params: actual, headers: headers
    assert_response :ok
    assert_equal(expected, TestController.last_request_parameters)
  end

  class WithoutRenderer < JsonApiRendererTest
    setup do
      require 'rails'
      require 'active_record'
      require 'support/rails5_shims'
      require 'active_model_serializers'
      require 'fixtures/poro'

      make_basic_app

      Rails.application.routes.draw do
        ActiveSupport::Deprecation.silence do
          match ':action', to: TestController, via: [:get, :post]
        end
      end
    end

    def test_jsonapi_parser_not_registered
      parsers = if Rails::VERSION::MAJOR >= 5
                  ActionDispatch::Request.parameter_parsers
                else
                  ActionDispatch::ParamsParser::DEFAULT_PARSERS
                end
      assert_nil parsers[Mime[:jsonapi]]
    end

    def test_jsonapi_renderer_not_registered
      expected = {
        'data' => {
          'attributes' => {
            'name' => 'Johnny Rico'
          },
          'type' => 'users'
        }
      }
      payload = '{"data": {"attributes": {"name": "Johnny Rico"}, "type": "authors"}}'
      headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
      post '/render_with_jsonapi_renderer', params: payload, headers: headers
      assert expected, response.body
    end

    def test_jsonapi_parser
      assert_parses(
        {},
        '',
        'CONTENT_TYPE' => 'application/vnd.api+json'
      )
    end
  end

  class WithRenderer < JsonApiRendererTest
    setup do
      require 'rails'
      require 'active_record'
      require 'support/rails5_shims'
      require 'active_model_serializers'
      require 'fixtures/poro'
      require 'active_model_serializers/register_jsonapi_renderer'

      make_basic_app

      Rails.application.routes.draw do
        ActiveSupport::Deprecation.silence do
          match ':action', to: TestController, via: [:get, :post]
        end
      end
    end

    def test_jsonapi_parser_registered
      if Rails::VERSION::MAJOR >= 5
        parsers = ActionDispatch::Request.parameter_parsers
        assert_equal Proc, parsers[:jsonapi].class
      else
        parsers = ActionDispatch::ParamsParser::DEFAULT_PARSERS
        assert_equal Proc, parsers[Mime[:jsonapi]].class
      end
    end

    def test_jsonapi_renderer_registered
      expected = {
        'data' => {
          'attributes' => {
            'name' => 'Johnny Rico'
          },
          'type' => 'users'
        }
      }
      payload = '{"data": {"attributes": {"name": "Johnny Rico"}, "type": "authors"}}'
      headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
      post '/render_with_jsonapi_renderer', params: payload, headers: headers
      assert expected, response.body
    end

    def test_jsonapi_parser
      assert_parses(
        {
          'data' => {
            'attributes' => {
              'name' => 'John Doe'
            },
            'type' => 'users'
          }
        },
        '{"data": {"attributes": {"name": "John Doe"}, "type": "users"}}',
        'CONTENT_TYPE' => 'application/vnd.api+json'
      )
    end
  end
end

require 'rails_helper'

module ActiveModelSerializers::Test::SchemaTest
  class MyController < ActionController::Base
    def index
      render json: profile
    end

    def show
      index
    end

    def name_as_a_integer
      profile.name = 1
      index
    end

    def render_using_json_api
      render json: profile, adapter: :json_api
    end

    def invalid_json_body
      render json: ''
    end

    private

    def profile
      @profile ||= Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
    end
  end
end

describe ActiveModelSerializers::Test::SchemaTest::MyController, type: :controller do
  routes { Routes }

  include ActiveModelSerializers::RSpecMatchers::Schema

  it 'test_that_assert_with_a_valid_schema' do
    get :index
    expect(response).to have_valid_schema
  end

  it 'test_that_raises_a_minitest_error_with_a_invalid_schema' do
    message = "#/name: failed schema #/properties/name: For 'properties/name', \"Name 1\" is not an integer. and #/description: failed schema #/properties/description: For 'properties/description', \"Description 1\" is not a boolean."

    get :show

    expect do
      expect(response).to have_valid_schema
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, message)
  end

  it 'test_that_raises_error_with_a_custom_message_with_a_invalid_schema' do
    message = 'oh boy the show is broken'
    exception_message = "#/name: failed schema #/properties/name: For 'properties/name', \"Name 1\" is not an integer. and #/description: failed schema #/properties/description: For 'properties/description', \"Description 1\" is not a boolean."
    expected_message = "#{message}: #{exception_message}"

    get :show

    expect do
      expect(response).to have_valid_schema nil, message
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, expected_message)
  end

  it 'test_that_assert_with_a_custom_schema' do
    get :show
    expect(response).to have_valid_schema 'custom/show.json'
  end

  it 'test_that_assert_with_a_hyper_schema' do
    get :show
    expect(response).to have_valid_schema 'hyper_schema.json'
  end

  it 'test_simple_json_pointers' do
    get :show
    expect(response).to have_valid_schema 'simple_json_pointers.json'
  end

  it 'test_simple_json_pointers_that_doesnt_match' do
    get :name_as_a_integer

    expect do
      expect(response).to have_valid_schema 'simple_json_pointers.json'
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'test_json_api_schema' do
    get :render_using_json_api
    expect(response).to have_valid_schema 'render_using_json_api.json'
  end

  it 'test_that_assert_with_a_custom_schema_directory' do
    original_schema_path = ActiveModelSerializers.config.schema_path
    ActiveModelSerializers.config.schema_path = 'test/support/custom_schemas'

    get :index
    expect(response).to have_valid_schema

    ActiveModelSerializers.config.schema_path = original_schema_path
  end

  it 'test_with_a_non_existent_file' do
    message = 'No Schema file at test/support/schemas/non-existent.json'

    get :show

    expect do
      expect(response).to have_valid_schema 'non-existent.json'
    end.to raise_error(ActiveModelSerializers::Test::Schema::MissingSchema)
  end

  it 'test_that_raises_with_a_invalid_json_body' do
    message = 'A JSON text must at least contain two octets!'

    get :invalid_json_body

    expect do
      expect(response).to have_valid_schema 'custom/show.json'
    end.to raise_error(ActiveModelSerializers::Test::Schema::InvalidSchemaError)
  end
end

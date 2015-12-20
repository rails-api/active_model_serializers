require 'test_helper'
require 'grape'
require 'grape/active_model_serializers'

class ActiveModelSerializers::GrapeTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  module Models
    def self.model1
      ARModels::Post.new(id: 1, title: 'Dummy Title', body: 'Lorem Ipsum')
    end

    def self.model2
      ARModels::Post.new(id: 2, title: 'Second Dummy Title', body: 'Second Lorem Ipsum')
    end

    def self.all
      @all ||=
      begin
        model1.save!
        model2.save!
        ARModels::Post.all
      end
    end
  end

  class GrapeTest < Grape::API
    format :json
    include Grape::ActiveModelSerializers

    resources :grape do
      get '/render' do
        render Models.model1
      end

      get '/render_with_json_api' do
        post = Models.model1
        render post, meta: { page: 1, total_pages: 2 }, adapter: :json_api
      end

      get '/render_array_with_json_api' do
        posts = Models.all
        render posts, adapter: :json_api
      end
    end
  end

  def app
    GrapeTest.new
  end

  def test_formatter_returns_json
    get '/grape/render'

    post = Models.model1
    serializable_resource = serializable(post)

    assert last_response.ok?
    assert_equal serializable_resource.to_json, last_response.body
  end

  def test_render_helper_passes_through_options_correctly
    get '/grape/render_with_json_api'

    post = Models.model1
    serializable_resource = serializable(post, serializer: ARModels::PostSerializer, adapter: :json_api, meta: { page: 1, total_pages: 2 })

    assert last_response.ok?
    assert_equal serializable_resource.to_json, last_response.body
  end

  def test_formatter_handles_arrays
    get '/grape/render_array_with_json_api'

    posts = Models.all
    serializable_resource = serializable(posts, adapter: :json_api)

    assert last_response.ok?
    assert_equal serializable_resource.to_json, last_response.body
  ensure
    ARModels::Post.delete_all
  end
end

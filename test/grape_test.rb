require 'test_helper'
require 'grape'
require 'grape/active_model_serializers'

class ActiveModelSerializers::GrapeTest < Minitest::Test
  include Rack::Test::Methods

  class GrapeTest < Grape::API
    format :json
    include Grape::ActiveModelSerializers

    resources :grape do
      get '/render' do
        render ARModels::Post.new(title: 'Dummy Title', body: 'Lorem Ipsum')
      end

      get '/render_with_json_api' do
        post = ARModels::Post.new(title: 'Dummy Title', body: 'Lorem Ipsum')
        render post, meta: { page: 1, total_pages: 2 }, adapter: :json_api
      end

      get '/render_array_with_json_api' do
        post = ARModels::Post.create(title: 'Dummy Title', body: 'Lorem Ipsum')
        post.dup.save
        render ARModels::Post.all, adapter: :json_api
      end
    end
  end

  def app
    GrapeTest.new
  end

  def test_formatter_returns_json
    get '/grape/render'

    post = ARModels::Post.new(title: 'Dummy Title', body: 'Lorem Ipsum')
    serializable_resource = serializable(post)

    assert last_response.ok?
    assert_equal serializable_resource.to_json, last_response.body
  end

  def test_render_helper_passes_through_options_correctly
    get '/grape/render_with_json_api'

    post = ARModels::Post.new(title: 'Dummy Title', body: 'Lorem Ipsum')
    serializable_resource = serializable(post, serializer: ARModels::PostSerializer, adapter: :json_api, meta: { page: 1, total_pages: 2 })

    assert last_response.ok?
    assert_equal serializable_resource.to_json, last_response.body
  end

  def test_formatter_handles_arrays
    get '/grape/render_array_with_json_api'

    expected = {
      'data' => [
        {
          id: '1',
          type: 'ar_models_posts',
          attributes: {
            title: 'Dummy Title',
            body: 'Lorem Ipsum'
          },
          relationships: {
            comments: { data: [] },
            author: { data: nil }
          }
        },
        {
          id: '2',
          type: 'ar_models_posts',
          attributes: {
            title: 'Dummy Title',
            body: 'Lorem Ipsum'
          },
          relationships: {
            comments: { data: [] },
            author: { data: nil }
          }
        }
      ]
    }

    assert last_response.ok?
    assert_equal expected.to_json, last_response.body
  end
end

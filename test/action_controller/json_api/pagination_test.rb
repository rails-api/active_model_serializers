require 'test_helper'
require 'will_paginate/array'
require 'kaminari'
require 'kaminari/hooks'
::Kaminari::Hooks.init

module ActionController
  module Serialization
    class JsonApi
      class PaginationTest < ActionController::TestCase
        class PaginationTestController < ActionController::Base
          def setup
            @array = [
              Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
              Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' }),
              Profile.new({ name: 'Name 3', description: 'Description 3', comments: 'Comments 3' })
            ]
          end

          def using_kaminari
            setup
            Kaminari.paginate_array(@array).page(params[:page]).per(params[:per_page])
          end

          def using_will_paginate
            setup
            @array.paginate(page: params[:page], per_page: params[:per_page])
          end

          def render_pagination_using_kaminari
            render json: using_kaminari, adapter: :json_api, pagination: true
          end

          def render_pagination_using_will_paginate
            render json: using_will_paginate, adapter: :json_api, pagination: true
          end

          def render_array_without_pagination_links
            render json: using_will_paginate, adapter: :json_api, pagination: false
          end

          def render_array_omitting_pagination_options
            render json: using_kaminari, adapter: :json_api
          end
        end

        tests PaginationTestController

        def test_render_pagination_links_with_will_paginate
          expected_links = {"first"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate?page=1&per_page=1",
            "prev"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate?page=1&per_page=1",
            "next"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate?page=3&per_page=1",
            "last"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate?page=3&per_page=1"}

          get :render_pagination_using_will_paginate, page: 2, per_page: 1
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_only_last_and_next_pagination_links
          expected_links = {"next"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate?page=2&per_page=2",
            "last"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate?page=2&per_page=2"}
          get :render_pagination_using_will_paginate, page: 1, per_page: 2
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_pagination_links_with_kaminari
          expected_links = {"first"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari?page=1&per_page=1",
            "prev"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari?page=1&per_page=1",
            "next"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari?page=3&per_page=1",
            "last"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari?page=3&per_page=1"}
          get :render_pagination_using_kaminari, page: 2, per_page: 1
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_only_prev_and_first_pagination_links
          expected_links = {"first"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari?page=1&per_page=1",
            "prev"=>"http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari?page=2&per_page=1"}
          get :render_pagination_using_kaminari, page: 3, per_page: 1
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_array_without_pagination_links
          get :render_array_without_pagination_links
          response = JSON.parse(@response.body)
          refute response.key? 'links'
        end

        def test_array_omitting_pagination_options
          get :render_array_omitting_pagination_options
          response = JSON.parse(@response.body)
          refute response.key? 'links'
        end
      end
    end
  end
end

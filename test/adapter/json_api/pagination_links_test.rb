require 'test_helper'
require 'will_paginate/array'
require 'kaminari'
require 'kaminari/hooks'
::Kaminari::Hooks.init

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class PaginationLinksTest < ActiveSupport::TestCase
        URI = 'http://example.com'.freeze

        setup do
          ActionController::Base.cache_store.clear
          @array = [
            Profile.new({ id: 1, name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
            Profile.new({ id: 2, name: 'Name 2', description: 'Description 2', comments: 'Comments 2' }),
            Profile.new({ id: 3, name: 'Name 3', description: 'Description 3', comments: 'Comments 3' }),
            Profile.new({ id: 4, name: 'Name 4', description: 'Description 4', comments: 'Comments 4' }),
            Profile.new({ id: 5, name: 'Name 5', description: 'Description 5', comments: 'Comments 5' })
          ]
        end

        def test_pagination_links_using_kaminari
          assert_links_serialization(expected_response_with_pagination_links, kaminari_collection, options)
        end

        def test_pagination_links_using_will_paginate
          assert_links_serialization(expected_response_with_pagination_links, will_paginate_collection, options)
        end

        def test_pagination_links_with_additional_params
          assert_links_serialization(expected_response_with_pagination_links_and_additional_params, will_paginate_collection, options(test: 'test'))
        end

        def test_pagination_config_set_to_false
          previous_config = ActiveModelSerializers.config.collection_serializer
          ActiveModelSerializers.config.collection_serializer = ActiveModel::Serializer::NonPaginatedCollectionSerializer
          assert_links_serialization(paginated_data, kaminari_collection, options)
        ensure
          ActiveModelSerializers.config.collection_serializer = previous_config
        end

        def test_not_showing_pagination_links
          assert_links_serialization(non_paginated_data, @array)
        end

        def test_non_paginated_serializer
          assert_links_serialization(paginated_data, kaminari_collection, options.merge(serializer: ActiveModel::Serializer::NonPaginatedCollectionSerializer))
        end

        def test_last_page_pagination_links_using_kaminari
          assert_links_serialization(expected_response_with_last_page_pagination_links, kaminari_collection(3), options)
        end

        def test_last_page_pagination_links_using_will_paginate
          assert_links_serialization(expected_response_with_last_page_pagination_links, will_paginate_collection(3), options)
        end

        private

        def options(query_parameters = {}, original_url = URI)
          context = Minitest::Mock.new
          context.expect(:nil?, false)
          context.expect(:request_url, original_url)
          context.expect(:query_parameters, query_parameters)
          context.expect(:key_transform, nil)
          { serialization_context: context }
        end

        def assert_links_serialization(expected_result, collection, options = {})
          options = options.merge(adapter: :json_api)
          serialized_collection = ActiveModel::SerializableResource.new(collection, options).as_json
          assert_equal expected_result, serialized_collection
        end

        def kaminari_collection(page = 2)
          Kaminari.paginate_array(@array).page(page).per(2)
        end

        def will_paginate_collection(page = 2)
          @array.paginate(page: page, per_page: 2)
        end

        def non_paginated_data
          {
            data: [
              { id: '1', type: 'profiles', attributes: { name: 'Name 1', description: 'Description 1' } },
              { id: '2', type: 'profiles', attributes: { name: 'Name 2', description: 'Description 2' } },
              { id: '3', type: 'profiles', attributes: { name: 'Name 3', description: 'Description 3' } },
              { id: '4', type: 'profiles', attributes: { name: 'Name 4', description: 'Description 4' } },
              { id: '5', type: 'profiles', attributes: { name: 'Name 5', description: 'Description 5' } }
            ]
          }
        end

        def paginated_data(range = (2..3))
          non_paginated_data.tap { |response| response[:data] = response[:data][range] }
        end

        def links
          {
            links: {
              self: "#{URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2",
              first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              prev: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              next: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2",
              last: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2"
            }
          }
        end

        def expected_response_with_last_page_pagination_links
          links = {
            links: {
              self: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2",
              first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              prev: "#{URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2"
            }
          }
          paginated_data(4..4).merge! links
        end

        def expected_response_with_pagination_links
          paginated_data.merge!(links)
        end

        def expected_response_with_pagination_links_and_additional_params
          links_with_param = links
          links_with_param[:links].each { |_, value| value << '&test=test' }
          paginated_data.merge! links_with_param
        end
      end
    end
  end
end

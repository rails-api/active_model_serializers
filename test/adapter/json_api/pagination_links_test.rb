# frozen_string_literal: true

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
        RECORDS_PER_PAGE = 2

        def setup
          ActionController::Base.cache_store.clear
          @array = [
            Profile.new(id: 1, name: 'Name 1', description: 'Description 1', comments: 'Comments 1'),
            Profile.new(id: 2, name: 'Name 2', description: 'Description 2', comments: 'Comments 2'),
            Profile.new(id: 3, name: 'Name 3', description: 'Description 3', comments: 'Comments 3'),
            Profile.new(id: 4, name: 'Name 4', description: 'Description 4', comments: 'Comments 4'),
            Profile.new(id: 5, name: 'Name 5', description: 'Description 5', comments: 'Comments 5')
          ]
        end

        def last_page_number
          (@array.size / RECORDS_PER_PAGE.to_f).ceil
        end

        def mock_request(query_parameters = {}, original_url = URI)
          context = Minitest::Mock.new
          context.expect(:request_url, original_url)
          context.expect(:query_parameters, query_parameters)
          context.expect(:key_transform, nil)
        end

        def load_adapter(paginated_collection, mock_request = nil)
          render_options = { adapter: :json_api }
          render_options[:serialization_context] = mock_request if mock_request
          serializable(paginated_collection, render_options)
        end

        def using_kaminari(page = 2)
          Kaminari.paginate_array(@array).page(page).per(RECORDS_PER_PAGE)
        end

        def using_will_paginate(page = 2)
          @array.paginate(page: page, per_page: RECORDS_PER_PAGE)
        end

        def data
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

        def empty_collection_links
          {
            self: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
            first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
            prev: nil,
            next: nil,
            last: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2"
          }
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

        def last_page_links
          {
            links: {
              self: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2",
              first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              prev: "#{URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2",
              next: nil,
              last: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2"
            }
          }
        end

        def links_without_last_page_link
          {
            links: {
              self: "#{URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2",
              first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              prev: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              next: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2",
              last: nil
            }
          }
        end

        def last_page_links_without_next_page_link
          {
            links: {
              self: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=2",
              first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
              prev: "#{URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2",
              next: nil,
              last: nil
            }
          }
        end

        def expected_response_when_unpaginatable
          data
        end

        def expected_response_with_pagination_links
          {}.tap do |hash|
            hash[:data] = data.values.flatten[2..3]
            hash.merge! links
          end
        end

        def expected_response_without_pagination_links
          {}.tap do |hash|
            hash[:data] = data.values.flatten[2..3]
          end
        end

        def expected_response_with_pagination_links_and_additional_params
          new_links = links[:links].each_with_object({}) { |(key, value), hash| hash[key] = "#{value}&test=test" }
          {}.tap do |hash|
            hash[:data] = data.values.flatten[2..3]
            hash.merge! links: new_links
          end
        end

        def expected_response_with_last_page_pagination_links
          {}.tap do |hash|
            hash[:data] = [data.values.flatten.last]
            hash.merge! last_page_links
          end
        end

        def expected_response_with_empty_collection_pagination_links
          {}.tap do |hash|
            hash[:data] = []
            hash.merge! links: empty_collection_links
          end
        end

        def test_pagination_links_using_kaminari
          adapter = load_adapter(using_kaminari, mock_request)

          assert_equal expected_response_with_pagination_links, adapter.serializable_hash
        end

        def test_pagination_links_using_will_paginate
          adapter = load_adapter(using_will_paginate, mock_request)

          assert_equal expected_response_with_pagination_links, adapter.serializable_hash
        end

        def test_pagination_links_with_additional_params
          adapter = load_adapter(using_will_paginate, mock_request(test: 'test'))

          assert_equal expected_response_with_pagination_links_and_additional_params,
            adapter.serializable_hash
        end

        def test_pagination_links_when_zero_results_kaminari
          @array = []

          adapter = load_adapter(using_kaminari(1), mock_request)

          assert_equal expected_response_with_empty_collection_pagination_links, adapter.serializable_hash
        end

        def test_pagination_links_when_zero_results_will_paginate
          @array = []

          adapter = load_adapter(using_will_paginate(1), mock_request)

          assert_equal expected_response_with_empty_collection_pagination_links, adapter.serializable_hash
        end

        def test_last_page_pagination_links_using_kaminari
          adapter = load_adapter(using_kaminari(last_page_number), mock_request)

          assert_equal expected_response_with_last_page_pagination_links, adapter.serializable_hash
        end

        def test_last_page_pagination_links_using_will_paginate
          adapter = load_adapter(using_will_paginate(last_page_number), mock_request)

          assert_equal expected_response_with_last_page_pagination_links, adapter.serializable_hash
        end

        def test_not_showing_pagination_links
          adapter = load_adapter(@array, mock_request)

          assert_equal expected_response_when_unpaginatable, adapter.serializable_hash
        end

        def test_raises_descriptive_error_when_serialization_context_unset
          render_options = { adapter: :json_api }
          adapter = serializable(using_kaminari, render_options)
          exception_class = ActiveModelSerializers::Adapter::JsonApi::PaginationLinks::MissingSerializationContextError

          exception = assert_raises(exception_class) do
            adapter.as_json
          end
          assert_equal exception_class, exception.class
          assert_match(/CollectionSerializer#paginated\?/, exception.message)
        end

        def test_pagination_links_not_present_when_disabled
          ActiveModel::Serializer.config.jsonapi_pagination_links_enabled = false
          adapter = load_adapter(using_kaminari, mock_request)

          assert_equal expected_response_without_pagination_links, adapter.serializable_hash
        ensure
          ActiveModel::Serializer.config.jsonapi_pagination_links_enabled = true
        end

        def test_last_link_not_present_when_using_jsonapi_omit_total_pages
          ActiveModel::Serializer.config.jsonapi_omit_total_pages = true

          collection = using_kaminari
          def collection.total_pages
            fail 'total_pages was called, but should not have been due to ' \
              '`ActiveModel::Serializer.config.jsonapi_omit_total_pages = true`'
          end
          adapter = load_adapter(collection, mock_request)

          expected_response = { data: data.values.flatten[2..3] }
          expected_response.merge!(links_without_last_page_link)

          assert_equal expected_response, adapter.serializable_hash
        ensure
          ActiveModel::Serializer.config.jsonapi_omit_total_pages = false
        end

        def test_next_link_not_present_on_last_page_when_using_jsonapi_omit_total_pages
          ActiveModel::Serializer.config.jsonapi_omit_total_pages = true

          collection = using_kaminari(last_page_number)
          def collection.total_pages
            fail 'total_pages was called, but should not have been due to ' \
              '`ActiveModel::Serializer.config.jsonapi_omit_total_pages = true`'
          end
          adapter = load_adapter(collection, mock_request)

          expected_response = { data: [data.values.flatten.last] }
          expected_response.merge!(last_page_links_without_next_page_link)

          assert_equal expected_response, adapter.serializable_hash
        ensure
          ActiveModel::Serializer.config.jsonapi_omit_total_pages = false
        end
      end
    end
  end
end

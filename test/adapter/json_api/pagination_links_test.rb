require 'test_helper'
require 'will_paginate/array'
require 'kaminari'
require 'kaminari/hooks'
::Kaminari::Hooks.init

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class PaginationLinksTest < ActiveSupport::TestCase
          URI = 'http://example.com'

          def setup
            ActionController::Base.cache_store.clear
            @array = [
              Profile.new({ id: 1, name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
              Profile.new({ id: 2, name: 'Name 2', description: 'Description 2', comments: 'Comments 2' }),
              Profile.new({ id: 3, name: 'Name 3', description: 'Description 3', comments: 'Comments 3' })
            ]
          end

          def mock_request(query_parameters = {}, original_url = URI)
            context = Minitest::Mock.new
            context.expect(:request_url, original_url)
            context.expect(:query_parameters, query_parameters)
            @options = {}
            @options[:serialization_context] = context
          end

          def load_adapter(paginated_collection, options = {})
            options = options.merge(adapter: :json_api)
            ActiveModel::SerializableResource.new(paginated_collection, options)
          end

          def using_kaminari
            Kaminari.paginate_array(@array).page(2).per(1)
          end

          def using_will_paginate
            @array.paginate(page: 2, per_page: 1)
          end

          def data
            { data: [
                { id: '1', type: 'profiles', attributes: { name: 'Name 1', description: 'Description 1' } },
                { id: '2', type: 'profiles', attributes: { name: 'Name 2', description: 'Description 2' } },
                { id: '3', type: 'profiles', attributes: { name: 'Name 3', description: 'Description 3' } }
              ]
            }
          end

          def links
            {
              links: {
                self: "#{URI}?page%5Bnumber%5D=2&page%5Bsize%5D=1",
                first: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                prev: "#{URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                next: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1",
                last: "#{URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1"
              }
            }
          end

          def expected_response_without_pagination_links
            data
          end

          def expected_response_with_pagination_links
            {}.tap do |hash|
              hash[:data] = [data.values.flatten.second]
              hash.merge! links
            end
          end

          def expected_response_with_pagination_links_and_additional_params
            new_links = links[:links].each_with_object({}) { |(key, value), hash| hash[key] = "#{value}&test=test" }
            {}.tap do |hash|
              hash[:data] = [data.values.flatten.second]
              hash.merge! links: new_links
            end
          end

          def test_pagination_links_using_kaminari
            adapter = load_adapter(using_kaminari)

            mock_request
            assert_equal expected_response_with_pagination_links, adapter.serializable_hash(@options)
          end

          def test_pagination_links_using_will_paginate
            adapter = load_adapter(using_will_paginate)

            mock_request
            assert_equal expected_response_with_pagination_links, adapter.serializable_hash(@options)
          end

          def test_pagination_links_with_additional_params
            adapter = load_adapter(using_will_paginate)

            mock_request({ test: 'test' })
            assert_equal expected_response_with_pagination_links_and_additional_params,
              adapter.serializable_hash(@options)
          end

          def test_not_showing_pagination_links
            adapter = load_adapter(@array)

            assert_equal expected_response_without_pagination_links, adapter.serializable_hash
          end
        end
      end
    end
  end
end

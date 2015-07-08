require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class PaginationTest < Minitest::Test
          def setup
            @posts = (1..100).map do |i|
              Post.new(id: i, title: "Post #{i}", body: "Body #{i}").tap do |post|
                post.comments = []
                post.author = Author.new(id: 1, name: 'Steve K.')
              end
            end
            @serializer = ActiveModel::Serializer::PaginationSerializer.new([@posts], page_size: 10, page_number: 1)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_pagination_links_for_first_page
            @serializer = ActiveModel::Serializer::PaginationSerializer.new([@posts], page_size: 10, page_number: 1)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)

            expected = {
              self:  "?page[size]=10&page[number]=1",
              first: "?page[size]=10&page[number]=1",
              last:  "?page[size]=10&page[number]=10",
              prev:  nil,
              next:  "?page[size]=10&page[number]=2"
            }

            assert_equal(expected, @adapter.serializable_hash[:links])
          end

          def test_pagination_links_for_middle_page
            @serializer = ActiveModel::Serializer::PaginationSerializer.new([@posts], page_size: 5, page_number: 5)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)

            expected = {
              self:  "?page[size]=5&page[number]=5",
              first: "?page[size]=5&page[number]=1",
              last:  "?page[size]=5&page[number]=20",
              prev:  "?page[size]=5&page[number]=4",
              next:  "?page[size]=5&page[number]=6"
            }

            assert_equal(expected, @adapter.serializable_hash[:links])
          end

          def test_pagination_links_for_last_page
            @serializer = ActiveModel::Serializer::PaginationSerializer.new([@posts], page_size: 9, page_number: 11)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)

            expected = {
              self:  "?page[size]=9&page[number]=11",
              first: "?page[size]=9&page[number]=1",
              last:  "?page[size]=9&page[number]=11",
              prev:  "?page[size]=9&page[number]=10",
              next:  nil,
            }

            assert_equal(expected, @adapter.serializable_hash[:links])
          end

        end
      end
    end
  end
end

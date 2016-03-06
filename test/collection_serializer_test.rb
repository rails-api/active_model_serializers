require 'test_helper'

module ActiveModel
  class Serializer
    class CollectionSerializerTest < ActiveSupport::TestCase
      include CollectionSerializerTesting

      setup do
        @comment = Comment.new
        @post = Post.new
        @resource = build_named_collection @comment, @post
        @serializer = collection_serializer.new(@resource, { some: :options })
      end

      def test_pagined_when_collection_respond_to_current_page_total_pages_and_size
        add_methods_to_resource(:total_pages, :size, :current_page)
        serializer = collection_serializer.new(@resource, { some: :options })
        assert(serializer.paginated?)
      end

      def test_not_paginated_when_collection_does_not_respond_to_current_page
        add_methods_to_resource(:total_pages, :size)
        refute(@serializer.paginated?)
      end

      def test_not_paginated_when_collection_does_not_respond_to_total_pages
        add_methods_to_resource(:current_page, :size)
        refute(@serializer.paginated?)
      end

      private

      def add_methods_to_resource(*methods)
        methods.each_with_object(@resource) do |method, resource|
          resource.define_singleton_method(method) {}
        end
      end

      def collection_serializer
        CollectionSerializer
      end
    end
  end
end

require 'test_helper'

module ActiveModel
  class Serializer
    class NonPaginatedCollectionSerializerTest < ActiveSupport::TestCase
      include CollectionSerializerTesting

      setup do
        @comment = Comment.new
        @post = Post.new
        @resource = build_named_collection @comment, @post
        @serializer = collection_serializer.new(@resource, some: :options)
      end

      def test_not_paginated
        refute(@serializer.paginated?)
      end

      private

      def collection_serializer
        NonPaginatedCollectionSerializer
      end
    end
  end
end

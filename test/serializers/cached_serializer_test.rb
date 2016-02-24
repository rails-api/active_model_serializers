require 'test_helper'
module ActiveModelSerializers
  module Adapter
    class CachedSerializerTest < ActiveSupport::TestCase
      def test_cached_false_without_cache_store
        cached_serializer = build do |serializer|
          serializer._cache = nil
        end
        refute cached_serializer.cached?
      end

      def test_cached_true_with_cache_store_and_without_cache_only_and_cache_except
        cached_serializer = build do |serializer|
          serializer._cache = Object
        end
        assert cached_serializer.cached?
      end

      def test_cached_false_with_cache_store_and_with_cache_only
        cached_serializer = build do |serializer|
          serializer._cache = Object
          serializer._cache_only = [:name]
        end
        refute cached_serializer.cached?
      end

      def test_cached_false_with_cache_store_and_with_cache_except
        cached_serializer = build do |serializer|
          serializer._cache = Object
          serializer._cache_except = [:content]
        end
        refute cached_serializer.cached?
      end

      def test_fragment_cached_false_without_cache_store
        cached_serializer = build do |serializer|
          serializer._cache = nil
          serializer._cache_only = [:name]
        end
        refute cached_serializer.fragment_cached?
      end

      def test_fragment_cached_true_with_cache_store_and_cache_only
        cached_serializer = build do |serializer|
          serializer._cache = Object
          serializer._cache_only = [:name]
        end
        assert cached_serializer.fragment_cached?
      end

      def test_fragment_cached_true_with_cache_store_and_cache_except
        cached_serializer = build do |serializer|
          serializer._cache = Object
          serializer._cache_except = [:content]
        end
        assert cached_serializer.fragment_cached?
      end

      def test_fragment_cached_false_with_cache_store_and_cache_except_and_cache_only
        cached_serializer = build do |serializer|
          serializer._cache = Object
          serializer._cache_except = [:content]
          serializer._cache_only = [:name]
        end
        refute cached_serializer.fragment_cached?
      end

      private

      def build
        serializer = Class.new(ActiveModel::Serializer)
        serializer._cache_key = nil
        serializer._cache_options = nil
        yield serializer if block_given?
        serializer_instance = serializer.new(Object)
        CachedSerializer.new(serializer_instance)
      end
    end
  end
end

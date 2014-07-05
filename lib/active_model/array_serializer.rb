require "active_support/core_ext/class/attribute"
require 'active_support/dependencies'
require 'active_support/descendants_tracker'

module ActiveModel
  # Active Model Array Serializer
  #
  # Serializes an Array, checking if each element implements
  # the +active_model_serializer+ method.
  #
  # To disable serialization of root elements:
  #
  #     ActiveModel::ArraySerializer.root = false
  #
  class ArraySerializer
    extend ActiveSupport::DescendantsTracker

    attr_reader :object, :options

    class_attribute :root

    class_attribute :cache
    class_attribute :perform_caching

    class << self
      # set perform caching like root
      def cached(value = true)
        self.perform_caching = value
      end
    end

    def initialize(object, options={})
      @object, @options = object, options
    end

    def meta_key
      @options[:meta_key].try(:to_sym) || :meta
    end

    def include_meta(hash)
      hash[meta_key] = @options[:meta] if @options.has_key?(:meta)
    end

    def as_json(*args)
      @options[:hash] = hash = {}
      @options[:unique_values] = {}

      if root = @options[:root]
        hash.merge!(root => serializable_array)
        include_meta hash
        hash
      else
        serializable_array
      end
    end

    def to_json(*args)
      if perform_caching?
        cache.fetch expand_cache_key([self.class.to_s.underscore, cache_key, 'to-json']) do
          super
        end
      else
        super
      end
    end

    def serializable_array
      if perform_caching?
        cache.fetch expand_cache_key([self.class.to_s.underscore, cache_key, 'serializable-array']) do
          _serializable_array
        end
      else
        _serializable_array
      end
    end

    private
    def _serializable_array
      @object.map do |item|
        if @options.has_key? :each_serializer
          serializer = @options[:each_serializer]
        elsif item.respond_to?(:active_model_serializer)
          serializer = item.active_model_serializer
        end

        serializable = serializer ? serializer.new(item, @options) : DefaultSerializer.new(item, @options.merge(:root => false))

        if serializable.respond_to?(:serializable_hash)
          serializable.serializable_hash
        else
          serializable.as_json
        end
      end
    end

    def expand_cache_key(*args)
      ActiveSupport::Cache.expand_cache_key(args)
    end

    def perform_caching?
      perform_caching && cache && respond_to?(:cache_key)
    end
  end
end

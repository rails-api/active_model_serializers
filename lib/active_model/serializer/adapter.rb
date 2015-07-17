require 'active_model/serializer/adapter/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      extend ActiveSupport::Autoload
      autoload :Json
      autoload :FlattenJson
      autoload :Null
      autoload :JsonApi

      attr_reader :serializer

      def initialize(serializer, options = {})
        @serializer = serializer
        @options = options
      end

      def serializable_hash(options = nil)
        raise NotImplementedError, 'This is an abstract method. Should be implemented at the concrete adapter.'
      end

      def as_json(options = nil)
        hash = serializable_hash(options)
        include_meta(hash) unless self.class == FlattenJson
        hash
      end

      def self.create(resource, options = {})
        override = options.delete(:adapter)
        klass = override ? adapter_class(override) : ActiveModel::Serializer.adapter
        klass.new(resource, options)
      end

      def self.adapter_class(adapter)
        adapter_name = adapter.to_s.classify.sub("API", "Api")
        "ActiveModel::Serializer::Adapter::#{adapter_name}".safe_constantize
      end

      def fragment_cache(*args)
        raise NotImplementedError, 'This is an abstract method. Should be implemented at the concrete adapter.'
      end

      private

      def cache_check(serializer)
        @cached_serializer = serializer
        @klass             = @cached_serializer.class
        if is_cached?
          @klass._cache.fetch(cache_key, @klass._cache_options) do
            yield
          end
        elsif is_fragment_cached?
          FragmentCache.new(self, @cached_serializer, @options).fetch
        else
          yield
        end
      end

      def is_cached?
        @klass._cache && !@klass._cache_only && !@klass._cache_except
      end

      def is_fragment_cached?
        @klass._cache_only && !@klass._cache_except || !@klass._cache_only && @klass._cache_except
      end

      def cache_key
        parts = []
        parts << object_cache_key
        parts << @klass._cache_digest unless @klass._cache_options && @klass._cache_options[:skip_digest]
        parts.join("/")
      end

      def object_cache_key
        object_time_safe = @cached_serializer.object.updated_at
        object_time_safe = object_time_safe.strftime("%Y%m%d%H%M%S%9N") if object_time_safe.respond_to?(:strftime)
        (@klass._cache_key) ? "#{@klass._cache_key}/#{@cached_serializer.object.id}-#{object_time_safe}" : @cached_serializer.object.cache_key
      end

      def meta
        serializer.meta if serializer.respond_to?(:meta)
      end

      def meta_key
        serializer.meta_key || "meta"
      end

      def root
        serializer.json_key.to_sym if serializer.json_key
      end

      def include_meta(json)
        json[meta_key] = meta if meta
        json
      end
    end
  end
end

module ActiveModel
  class Serializer
    class Adapter
      class FragmentCache

        attr_reader :serializer

        def initialize(adapter, serializer, options, root)
          @root       = root
          @options    = options
          @adapter    = adapter
          @serializer = serializer
        end

        def fetch
          klass = serializer.class
          # It will split the serializer into two, one that will be cached and other wont
          serializers = fragment_serializer(serializer.object.class.name, klass)

          # Instanciate both serializers
          cached_serializer     = serializers[:cached].constantize.new(serializer.object)
          non_cached_serializer = serializers[:non_cached].constantize.new(serializer.object)

          cached_adapter     = @adapter.class.new(cached_serializer, @options)
          non_cached_adapter = @adapter.class.new(non_cached_serializer, @options)

          # Get serializable hash from both
          cached_hash     = cached_adapter.serializable_hash
          non_cached_hash = non_cached_adapter.serializable_hash

          # Merge both results
          @adapter.fragment_cache(cached_hash, non_cached_hash)
        end

        def format(name)
          name.split('::').map(&:camelize).join('::')
        end

        def get_scope(name)
          scope = name.rpartition('::').first
          scope.empty? ? Object : scope.constantize
        end

        private

        def cached_attributes(klass, serializers)
          cached_attributes     = (klass._cache_only) ? klass._cache_only : serializer.attributes.keys.delete_if {|attr| klass._cache_except.include?(attr) }
          non_cached_attributes = serializer.attributes.keys.delete_if {|attr| cached_attributes.include?(attr) }

          cached_attributes.each do |attribute|
            options = serializer.class._attributes_keys[attribute]
            options ||= {}
            # Add cached attributes to cached Serializer
            serializers[:cached].constantize.attribute(attribute, options)
          end

          non_cached_attributes.each do |attribute|
            options = serializer.class._attributes_keys[attribute]
            options ||= {}
            # Add non-cached attributes to non-cached Serializer
            serializers[:non_cached].constantize.attribute(attribute, options)
          end
        end

        def fragment_serializer(name, klass)
          cached     = "#{format(name)}CachedSerializer"
          non_cached = "#{format(name)}NonCachedSerializer"

          scope = get_scope(name)

          last_cached = cached.rpartition('::').last
          last_non_cached = non_cached.rpartition('::').last

          scope.const_set last_cached, Class.new(ActiveModel::Serializer) unless scope.const_defined?(last_cached)
          scope.const_set last_non_cached, Class.new(ActiveModel::Serializer) unless scope.const_defined?(last_non_cached)

          klass._cache_options       ||= {}
          klass._cache_options[:key] = klass._cache_key if klass._cache_key

          cached.constantize.cache(klass._cache_options)

          cached.constantize.fragmented(serializer)
          non_cached.constantize.fragmented(serializer)

          serializers = {cached: cached, non_cached: non_cached}
          cached_attributes(klass, serializers)
          serializers
        end
      end
    end
  end
end
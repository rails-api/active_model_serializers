module ActiveModel
  class Serializer
    module Adapter
      class FragmentCache
        attr_reader :serializer

        def initialize(adapter, serializer, options)
          @instance_options = options
          @adapter    = adapter
          @serializer = serializer
        end

        # TODO: Use Serializable::Resource
        # TODO: call +constantize+ less
        # 1. Create a CachedSerializer and NonCachedSerializer from the serializer class
        # 2. Serialize the above two with the given adapter
        # 3. Pass their serializations to the adapter +::fragment_cache+
        def fetch
          klass = serializer.class
          # It will split the serializer into two, one that will be cached and one that will not
          serializers = fragment_serializer(serializer.object.class.name, klass)

          # Instantiate both serializers
          cached_serializer     = serializers[:cached].constantize.new(serializer.object)
          non_cached_serializer = serializers[:non_cached].constantize.new(serializer.object)

          cached_adapter     = adapter.class.new(cached_serializer, instance_options)
          non_cached_adapter = adapter.class.new(non_cached_serializer, instance_options)

          # Get serializable hash from both
          cached_hash     = cached_adapter.serializable_hash
          non_cached_hash = non_cached_adapter.serializable_hash

          # Merge both results
          adapter.fragment_cache(cached_hash, non_cached_hash)
        end

        protected

        attr_reader :instance_options, :adapter

        private

        # Given a serializer class and a hash of its cached and non-cached serializers
        # 1. Determine cached attributes from serializer class options
        # 2. Add cached attributes to cached Serializer
        # 3. Add non-cached attributes to non-cached Serializer
        def cached_attributes(klass, serializers)
          attributes            = serializer.class._attributes
          cached_attributes     = (klass._cache_only) ? klass._cache_only : attributes.reject { |attr| klass._cache_except.include?(attr) }
          non_cached_attributes = attributes - cached_attributes

          cached_attributes.each do |attribute|
            add_attribute_to_serializer(attribute, serializers, :cached)
          end

          non_cached_attributes.each do |attribute|
            add_attribute_to_serializer(attribute, serializers, :non_cached)
          end
        end

        # Given an attribute and the key of its serializer
        # 1. Add attribute to the appropriate cached or non-cached Serializer
        def add_attribute_to_serializer(attribute, serializers, key)
          options = serializer.class._attributes_keys[attribute]
          options ||= {}
          # Add attributes to Serializer
          serializers[key].constantize.attribute(attribute, options)
        end

        # Given a resource name and its serializer's class
        # 1. Dyanmically creates a CachedSerializer and NonCachedSerializer
        #   for a given class 'name'
        # 2. Call
        #       CachedSerializer.cache(serializer._cache_options)
        #       CachedSerializer.fragmented(serializer)
        #       NontCachedSerializer.cache(serializer._cache_options)
        # 3. Build a hash keyed to the +cached+ and +non_cached+ serializers
        # 4. Call +cached_attributes+ on the serializer class and the above hash
        # 5. Return the hash
        #
        # @example
        #   When +name+ is <tt>User::Admin</tt>
        #   creates the Serializer classes (if they don't exist).
        #     User_AdminCachedSerializer
        #     User_AdminNOnCachedSerializer
        #
        def fragment_serializer(name, klass)
          cached     = "#{to_valid_const_name(name)}CachedSerializer"
          non_cached = "#{to_valid_const_name(name)}NonCachedSerializer"

          Object.const_set cached, Class.new(ActiveModel::Serializer) unless Object.const_defined?(cached)
          Object.const_set non_cached, Class.new(ActiveModel::Serializer) unless Object.const_defined?(non_cached)

          klass._cache_options ||= {}
          klass._cache_options[:key] = klass._cache_key if klass._cache_key

          cached.constantize.cache(klass._cache_options)

          # Preserve the type setting in the cached/non-cached serializer classes
          cached.constantize.type(klass._type)
          non_cached.constantize.type(klass._type)

          cached.constantize.fragmented(serializer)
          non_cached.constantize.fragmented(serializer)

          serializers = { cached: cached, non_cached: non_cached }
          cached_attributes(klass, serializers)
          serializers
        end

        def to_valid_const_name(name)
          name.gsub('::', '_')
        end
      end
    end
  end
end

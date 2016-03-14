module ActiveModelSerializers
  class FragmentCache
    attr_reader :serializer

    def initialize(adapter, serializer, options)
      @instance_options = options
      @adapter    = adapter
      @serializer = serializer
    end

    # 1. Create a CachedSerializer and NonCachedSerializer from the serializer class
    # 2. Serialize the above two with the given adapter
    # 3. Pass their serializations to the adapter +::fragment_cache+
    def fetch
      object = serializer.object

      # It will split the serializer into two, one that will be cached and one that will not
      serializers = fragment_serializer(object.class.name)

      # Get serializable hash from both
      cached_hash     = serialize(object, serializers[:cached])
      non_cached_hash = serialize(object, serializers[:non_cached])

      # Merge both results
      adapter.fragment_cache(cached_hash, non_cached_hash)
    end

    protected

    attr_reader :instance_options, :adapter

    private

    def serialize(object, serializer_class)
      ActiveModel::SerializableResource.new(
        object,
        serializer: serializer_class,
        adapter: adapter.class
      ).serializable_hash
    end

    # Given a hash of its cached and non-cached serializers
    # 1. Determine cached attributes from serializer class options
    # 2. Add cached attributes to cached Serializer
    # 3. Add non-cached attributes to non-cached Serializer
    def cache_attributes(serializers)
      klass                 = serializer.class
      attributes            = klass._attributes
      cache_only            = klass._cache_only
      cached_attributes     = cache_only ? cache_only : attributes - klass._cache_except
      non_cached_attributes = attributes - cached_attributes
      attributes_keys       = klass._attributes_keys

      add_attributes_to_serializer(serializers[:cached], cached_attributes, attributes_keys)
      add_attributes_to_serializer(serializers[:non_cached], non_cached_attributes, attributes_keys)
    end

    def add_attributes_to_serializer(serializer, attributes, attributes_keys)
      attributes.each do |attribute|
        options = attributes_keys[attribute] || {}
        serializer.attribute(attribute, options)
      end
    end

    # Given a resource name
    # 1. Dynamically creates a CachedSerializer and NonCachedSerializer
    #   for a given class 'name'
    # 2. Call
    #       CachedSerializer.cache(serializer._cache_options)
    #       CachedSerializer.fragmented(serializer)
    #       NonCachedSerializer.cache(serializer._cache_options)
    # 3. Build a hash keyed to the +cached+ and +non_cached+ serializers
    # 4. Call +cached_attributes+ on the serializer class and the above hash
    # 5. Return the hash
    #
    # @example
    #   When +name+ is <tt>User::Admin</tt>
    #   creates the Serializer classes (if they don't exist).
    #     User_AdminCachedSerializer
    #     User_AdminNonCachedSerializer
    #
    def fragment_serializer(name)
      klass      = serializer.class
      cached     = "#{to_valid_const_name(name)}CachedSerializer"
      non_cached = "#{to_valid_const_name(name)}NonCachedSerializer"

      cached_serializer     = get_or_create_serializer(cached)
      non_cached_serializer = get_or_create_serializer(non_cached)

      klass._cache_options ||= {}
      cache_key = klass._cache_key
      klass._cache_options[:key] = cache_key if cache_key
      cached_serializer.cache(klass._cache_options)

      type = klass._type
      cached_serializer.type(type)
      non_cached_serializer.type(type)

      non_cached_serializer.fragmented(serializer)
      cached_serializer.fragmented(serializer)

      serializers = { cached: cached_serializer, non_cached: non_cached_serializer }
      cache_attributes(serializers)
      serializers
    end

    def get_or_create_serializer(name)
      return Object.const_get(name) if Object.const_defined?(name)
      Object.const_set(name, Class.new(ActiveModel::Serializer))
    end

    def to_valid_const_name(name)
      name.gsub('::', '_')
    end
  end
end

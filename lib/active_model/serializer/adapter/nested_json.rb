module ActiveModel
  class Serializer
    class Adapter
      class NestedJson < Adapter
        cattr_accessor :default_limit_depth
        self.default_limit_depth = 5

        def serializable_hash options = {}
          @current_depth = options[:_current_depth] || 0
          @limit_depth = options[:limit_depth] || default_limit_depth
          check_depth!

          @result =
            serialize_collection(serializer, options) ||
            serialize_attributes(options).merge(serialize_associations)
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

        private
        def serialize_object serializer, options = {}
          if serializer.try(:object)
            options = options.merge(_current_depth: @current_depth + 1, limit_depth: @limit_depth)
            self.class.new(serializer).serializable_hash(options)
          end
        end

        def serialize_collection serializers, options = {}
          if serializers.respond_to?(:each)
            serializers.map { |s| serialize_object(s, options) }
          end
        end

        def serialize_attributes options
          cache_check(serializer) do
            serializer.attributes(options)
          end
        end

        def serialize_associations
          hash = {}
          serializer.associations.each do |association|
            serializer = association.serializer
            opts = association.options
            hash[association.key] =
              serialize_collection(serializer, opts) ||
              serialize_object(serializer, opts) ||
              opts[:virtual_value]
          end
          hash
        end

        def check_depth!
          if @current_depth > @limit_depth
            fail 'Too deep associations.'
          end
        end
      end
    end
  end
end

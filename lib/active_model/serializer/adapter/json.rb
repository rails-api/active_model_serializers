require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        cattr_accessor :default_limit_depth, :default_check_depth_strategy
        self.default_limit_depth = 1
        self.default_check_depth_strategy = :trim

        def serializable_hash options = nil
          options ||= {}
          @current_depth = options[:_current_depth] || 0
          @without_root = options[:_without_root]
          @limit_depth = options[:limit_depth] || default_limit_depth
          @check_depth_strategy = options[:check_depth_strategy] || default_check_depth_strategy

          @result =
            serialize_collection(serializer, options.merge(_without_root: true)) ||
            serialize_attributes(options).merge(serialize_associations)
          rooting? ? { root => @result } : @result
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

        private

        def rooting?
          !@without_root && (@current_depth == 0)
        end

        def serialize_object serializer, options = {}
          if serializer.try(:object)
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
          next_depth = @current_depth + 1
          cascading_options = {
            limit_depth: @limit_depth,
            check_depth_strategy: @check_depth_strategy,
            _current_depth: next_depth
          }
          unless too_deep? next_depth
            serializer.associations.each do |association|
              serializer = association.serializer
              opts = association.options.merge(cascading_options)
              hash[association.key] =
                serialize_collection(serializer, opts) ||
                serialize_object(serializer, opts) ||
                opts[:virtual_value]
            end
          end
          hash
        end

        def too_deep? depth
          if depth > @limit_depth
            case @check_depth_strategy
            when :fail
              fail 'Too deep associations.'
            when :trim
              true
            end
          else
            false
          end
        end
      end
    end
  end
end

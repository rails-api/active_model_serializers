module ActiveModel
  class Serializer
    class Adapter
      class NestedJson < Json
        cattr_accessor :default_limit_depth
        @@default_limit_depth = 5

        def serializable_hash options = {}
          @current_depth = options[:_current_depth] || 0
          @limit_depth = options[:limit_depth] || default_limit_depth
          check_depth!

          if serializer.respond_to?(:each)
            @result = serialize_collection(serializer, options)
          else
            @hash = {}

            @core = cache_check(serializer) do
              serializer.attributes(options)
            end

            serializer.associations.each do |association|
              serializer = association.serializer
              opts = association.options

              if serializer.respond_to?(:each)
                @hash[association.key] = serialize_collection(serializer, opts)
              elsif serializer && serializer.object
                @hash[association.key] = serialize_object(serializer, opts)
              else
                @hash[association.key] = opts[:virtual_value]
              end
            end
            @result = @core.merge @hash
          end

          @result
        end

        def serialize_object serializer, options = {}
          options = options.merge(_current_depth: @current_depth + 1, limit_depth: @limit_depth)
          self.class.new(serializer).serializable_hash(options)
        end

        def serialize_collection serializers, options = {}
          serializers.map { |s| serialize_object(s, options) }
        end

        def check_depth!
          if @current_depth > @limit_depth
            fail "associations are too deep."
          end
        end
      end
    end
  end
end

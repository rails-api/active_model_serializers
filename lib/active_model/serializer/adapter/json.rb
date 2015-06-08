require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root = true if @options[:root]
        end

        def serializable_hash(options = {})
          if serializer.respond_to?(:each)
            @result = serializer.map{|s| self.class.new(s).serializable_hash }
          else
            @hash = {}

            @core = cache_check(serializer) do
              serializer.attributes(options)
            end

            serializer.each_association do |name, association, opts|
              if association.respond_to?(:each)
                array_serializer = association
                @hash[name] = array_serializer.map do |item|
                  cache_check(item) do
                    item.attributes(opts)
                  end
                end
              else
                if association && association.object
                  @hash[name] = cache_check(association) do
                    association.attributes(options)
                  end
                elsif opts[:virtual_value]
                  @hash[name] = opts[:virtual_value]
                else
                  @hash[name] = nil
                end
              end
            end
            @result = @core.merge @hash
          end

          if root = options.fetch(:root, serializer.json_key)
            @result = { root => @result }
          end
          @result
        end
      end

      def fragment_cache(cached_hash, non_cached_hash)
        Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
      end
    end
  end
end
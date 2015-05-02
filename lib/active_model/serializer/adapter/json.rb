require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = {})
          if serializer.respond_to?(:each)
            @result = serializer.map{|s| self.class.new(s).serializable_hash }
          else
            @hash = {}

            @core = cache_check(serializer) do
              serializer.attributes(options)
            end

            serializer.each_association do |name, association, opts|
              populate_hash_for_array_serializer(name, association, opts)
              populate_hash(name, association, opts, options)
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

      private

      def populate_hash_for_array_serializer(name, association, opts)
        return unless association.respond_to?(:each)

        array_serializer = association
        @hash[name] = array_serializer.map do |item|
          cache_check(item) do
            item.attributes(opts)
          end
        end
      end

      def populate_hash(name, association, opts, options)
        return if association.respond_to?(:each)

        @hash[name] = nil
        if association
          @hash[name] = cache_check(association) do
            association.attributes(options)
          end
        elsif opts[:virtual_value]
          @hash[name] = opts[:virtual_value]
        end
      end
    end
  end
end

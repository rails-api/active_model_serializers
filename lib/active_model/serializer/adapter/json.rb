class ActiveModel::Serializer::Adapter::Json < ActiveModel::Serializer::Adapter
        extend ActiveSupport::Autoload
        autoload :FragmentCache

        # rubocop:disable Metrics/AbcSize
        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            result = serializer.map { |s| FlattenJson.new(s).serializable_hash(options) }
          else
            hash = {}

            core = cache_check(serializer) do
              serializer.attributes(options)
            end

            core = core.each_with_object({}) do |(name, value), formatted_hash|
              formatted_hash[format_key(name)] = value
            end

            serializer.associations.each do |association|
              serializer = association.serializer
              association_options = association.options

              if serializer.respond_to?(:each)
                array_serializer = serializer
                formatted_association_key = format_key(association.key)

                hash[formatted_association_key] = array_serializer.map do |item|
                  attributes = cache_check(item) do
                    item.attributes(association_options)
                  end

                  attributes.each_with_object({}) do |(name, value), formatted_hash|
                    formatted_hash[format_key(name)] = value
                  end
                end
              else
                formatted_association_key = format_key(association.key)

                hash[formatted_association_key] =
                  if serializer && serializer.object
                    attributes = cache_check(serializer) do
                      serializer.attributes(options)
                    end

                    attributes.each_with_object({}) do |(name, value), formatted_hash|
                      formatted_hash[format_key(name)] = value
                    end
                  elsif association_options[:virtual_value]
                    association_options[:virtual_value]
                  end
              end
            end
            result = core.merge hash
          end

          { root => result }
        end
        # rubocop:enable Metrics/AbcSize

        def default_key_format
          :lower_camel
        end

        def fragment_cache(cached_hash, non_cached_hash)
          ActiveModel::Serializer::Adapter::Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end
end

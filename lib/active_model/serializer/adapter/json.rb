require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = nil)
          options ||= {}
          sideload = ActiveModel::Serializer.config.sideload_associations

          if serializer.respond_to?(:each)
            @result = serializer.map { |s| FlattenJson.new(s).serializable_hash(options) }
          else
            @hash = {}

            @core = cache_check(serializer) do
              serializer.attributes(options)
            end

            serializer.associations.each do |association|
              serializer = association.serializer
              opts = association.options
              
              if serializer.respond_to?(:each)
                array_serializer = serializer
                @hash[association.key] = array_serializer.map do |item|
                  cache_check(item) do
                    item.attributes(opts)
                  end
                end
              else
                @hash[association.key] =
                  if serializer && serializer.object
                    cache_check(serializer) do
                      serializer.attributes(options)
                    end
                  elsif opts[:virtual_value]
                    opts[:virtual_value]
                  end
              end
            end

            if sideload
              association_ids = {}
              @hash.map do |association_name, associated_models|
                # TODO: use active support inflectors?
                letters = association_name.to_s.split('')
                letters = letters[0..letters.length - 2] if letters.last == 's'
                singular_name = letters.join
                id_name = (singular_name.singularize + "_ids").to_sym

                # build id list
                association_ids[id_name] ||= []

                ids = Array.wrap(associated_models).map{ |model_hash|
                  model_hash[:id]
                }
                association_ids[id_name] = ids
              end
              @result = @core.merge association_ids
            else
              @result = @core.merge @hash
            end
          end

          if sideload
            { root => @result }.merge(@hash || {})
          else
            { root => @result }
          end
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

      end
    end
  end
end

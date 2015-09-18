class ActiveModel::Serializer::Adapter::Json < ActiveModel::Serializer::Adapter
        extend ActiveSupport::Autoload
        autoload :FragmentCache

        def initialize(serializer, options = {})
          super
          @included = ActiveModel::Serializer::Utils.include_args_to_hash(instance_options[:include] || '*')
        end

        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            result = serializer.map { |s| FlattenJson.new(s, include: @included).serializable_hash(options) }
          else
            hash = {}

            core = cache_check(serializer) do
              serializer.attributes(options)
            end

            included_associations = serializer.expand_includes(@included)
            included_associations.each do |association, assoc_includes|
              hash[association.key] =
                if association.options[:virtual_value]
                  association.options[:virtual_value]
                elsif association.serializer && association.serializer.object
                  FlattenJson.new(association.serializer, association.options.merge(include: assoc_includes))
                    .serializable_hash(options)
                end
            end
            result = core.merge hash
          end

          { root => result }
        end

        def fragment_cache(cached_hash, non_cached_hash)
          ActiveModel::Serializer::Adapter::Json::FragmentCache.new.fragment_cache(cached_hash, non_cached_hash)
        end
end

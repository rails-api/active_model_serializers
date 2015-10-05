module ActiveModel
  class Serializer
    module Adapter
      class Json < Base
        extend ActiveSupport::Autoload
        autoload :FragmentCache

        def serializable_hash(options = nil)
          options ||= {}
          { root => Attributes.new(serializer, instance_options).serializable_hash(options) }
        end

        private

        def fragment_cache(cached_hash, non_cached_hash)
          ActiveModel::Serializer::Adapter::Json::FragmentCache.new.fragment_cache(cached_hash, non_cached_hash)
        end

        def root
          root = instance_options.fetch(:root) do
            if serializer.respond_to?(:each)
              serializer.first.object.class.model_name.to_s.pluralize
            else
              serializer.object.class.model_name.to_s
            end
          end

          root.underscore.to_sym
        end
      end
    end
  end
end

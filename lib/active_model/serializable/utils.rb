module ActiveModel
  module Serializable
    module Utils
      extend self

      def _const_get(const)
        Serializer.serializers_cache.fetch_or_store(const) do
          begin
            method = RUBY_VERSION >= '2.0' ? :const_get : :qualified_const_get
            Object.send method, const
          rescue NameError
            const.safe_constantize
          end
        end
      end
    end
  end
end

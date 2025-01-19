# frozen_string_literal: true

module ActiveModel
  class Serializer
    class Fieldset
      CONCURRENT_MAP_AVAILABLE = defined?(Concurrent::Map)

      def initialize(fields)
        @raw_fields = fields || {}
        @fields_for_cache = Concurrent::Map.new if CONCURRENT_MAP_AVAILABLE
      end

      def fields
        @fields ||= parsed_fields
      end

      def fields_for(type)
        if CONCURRENT_MAP_AVAILABLE
          @fields_for_cache.fetch_or_store(type) do
            compute_fields_for(type)
          end
        else
          compute_fields_for(type)
        end
      end

      protected

      attr_reader :raw_fields

      private

      def parsed_fields
        if raw_fields.is_a?(Hash)
          raw_fields.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.map(&:to_sym) }
        else
          {}
        end
      end

      def compute_fields_for(type)
        singular_type = type.to_s.singularize.to_sym
        plural_type = type.to_s.pluralize.to_sym
        fields[singular_type] || fields[plural_type]
      end
    end
  end
end

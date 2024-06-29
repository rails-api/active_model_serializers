# frozen_string_literal: true

module ActiveModel
  class Serializer
    class Fieldset
      def initialize(fields)
        @raw_fields = fields || {}
      end

      def fields
        @fields ||= parsed_fields
      end

      def fields_for(type)
        @fields_for_cache ||= {}
        return @fields_for_cache[type] if @fields_for_cache.key?(type)

        singular_type = type.to_s.singularize.to_sym
        plural_type = type.to_s.pluralize.to_sym
        result = fields[singular_type] || fields[plural_type]

        @fields_for_cache[type] = result
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
    end
  end
end

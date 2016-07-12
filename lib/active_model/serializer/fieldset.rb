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
        fields[type.singularize.to_sym] || fields[type.pluralize.to_sym]
      end

      protected

      attr_reader :raw_fields

      private

      def parsed_fields
        # TODO: this is not very flexible.
        # - we should probably support symbol, array, hash, etc
        #
        # JSONAPI::IncludeDirective supports these, but also changes the resulting structure.
        # is it worth it to duplicate some of that functionality?
        # or should IncludeDirective be modified to only allow one layer of options?
        if raw_fields.is_a?(Hash)
          symbolize_hash(raw_fields)
        else
          {}
        end
      end

      def symbolize_hash(hash)
        hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.map(&:to_sym) }
      end
    end
  end
end

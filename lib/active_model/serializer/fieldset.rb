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
        JSONAPI::IncludeDirective.new(raw_fields).to_hash
      end
    end
  end
end

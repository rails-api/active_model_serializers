module ActiveModel
  class Serializer
    class Fieldset

      def initialize(fields, root = nil)
        @root       = root
        @raw_fields = fields
      end

      def fields
        @fields ||= parsed_fields
      end

      def fields_for(serializer)
        key = serializer.json_key
        fields[key.to_sym] || fields[key.pluralize.to_sym]
      end

    private

      ActiveModelSerializers.silence_warnings do
      attr_reader :raw_fields, :root
      end

      def parsed_fields
        if raw_fields.is_a?(Hash)
          raw_fields.inject({}) { |h,(k,v)| h[k.to_sym] = v.map(&:to_sym); h}
        elsif raw_fields.is_a?(Array)
          if root.nil?
            raise ArgumentError, 'The root argument must be specified if the fileds argument is an array.'
          end
          hash = {}
          hash[root.to_sym] = raw_fields.map(&:to_sym)
          hash
        else
          {}
        end
      end

    end
  end
end

module ActiveModel
  class Serializer
    class Fieldset

      attr_accessor :fields, :root

      def initialize(serializer, fields = {})
        @root   = serializer.json_key
        @fields = parse(fields)
      end

      def fields_for(serializer)
        key = serializer.json_key || serializer.class.root_name
        fields[key]
      end

    private

      def parse(fields)
        if fields.is_a?(Hash)
          fields.inject({}) { |h,(k,v)| h[k.to_s] = v.map(&:to_sym); h}
        elsif fields.is_a?(Array)
          hash = {}
          hash[root.to_s] = fields.map(&:to_sym)
          hash
        else
          {}
        end
      end

    end
  end
end
module ActiveModel
  class Serializer
    class Fieldset

      attr_reader :fields, :root

      def initialize(fields, root = nil)
        @root   = root
        @fields = parse(fields)
      end

      def fields_for(serializer)
        key = serializer.json_key || serializer.class.root_name
        fields[key.to_sym]
      end

    private

      def parse(fields)
        if fields.is_a?(Hash)
          fields.inject({}) { |h,(k,v)| h[k.to_sym] = v.map(&:to_sym); h}
        elsif fields.is_a?(Array)
          if root.nil?
            raise ArgumentError, 'The root argument must be specified if the fileds argument is an array.'
          end
          hash = {}
          hash[root.to_sym] = fields.map(&:to_sym)
          hash
        else
          {}
        end
      end

    end
  end
end
module ActiveModel
  class Serializer
    class Adapter
      extend ActiveSupport::Autoload
      autoload :SimpleAdapter
      autoload :NullAdapter

      attr_reader :serializer

      def initialize(serializer)
        @serializer = serializer
      end

      def serializable_hash(options = {})
        raise NotImplementedError, 'This is abstract method. Should be implemented at concrete adapter.'
      end

      def to_json(options={})
        serializable_hash(options).to_json
      end

      def self.adapter_for(serializer)
        adapter_class = case serializer.config.adapter
                        when Symbol
                          class_name = "ActiveModel::Serializer::Adapter::#{serializer.config.adapter.to_s.classify}Adapter"
                          if Object.const_defined?(class_name)
                            Object.const_get(class_name)
                          end
                        when Class
                          serializer.config.adapter
                        end
        unless adapter_class
          valid_adapters = self.constants.map { |klass| ":#{klass.to_s.sub('Adapter', '').downcase}" }
          raise ArgumentError, "Unknown adapter: #{serializer.config.adapter}. Valid adapters are: #{valid_adapters}"
        end

        adapter_class.new(serializer)
      end
    end
  end
end

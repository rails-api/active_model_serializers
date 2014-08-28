module ActiveModel
  class Serializer
    class Adapter
      extend ActiveSupport::Autoload
      autoload :SimpleAdapter
      autoload :NullAdapter
      autoload :JsonApiAdapter

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
    end
  end
end

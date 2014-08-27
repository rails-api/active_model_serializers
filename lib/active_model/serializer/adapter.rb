module ActiveModel
  class Serializer
    class Adapter
      extend ActiveSupport::Autoload
      autoload :SimpleAdapter
      autoload :NullAdapter

      def initialize(serializer)
        @attributes = serializer.attributes
      end

      def serializable_hash(options = {})
        raise NotImplementedError, 'This is abstract method. Should be implemented at concrete adapter.'
      end

      def to_json(options = {})
        raise NotImplementedError, 'This is abstract method. Should be implemented at concrete adapter.'
      end
    end
  end
end

module ActiveModelSerializers
  module Adapter
    class Json < Base
      def serializable_hash(options = nil)
        options ||= {}
        { root => Attributes.new(serializer, instance_options).serializable_hash(options) }
      end
    end
  end
end

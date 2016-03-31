module ActiveModelSerializers
  module Adapter
    class Json < Base
      def serializable_hash(options = nil)
        options ||= {}
        serialized_hash = { root => Attributes.new(serializer, instance_options).serializable_hash(options) }
        self.class.transform_key_casing!(serialized_hash, options)
      end
    end
  end
end

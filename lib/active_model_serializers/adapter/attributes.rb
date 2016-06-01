module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def serializable_hash(options = nil)
        options = serialization_options(options)
        serializer.serialize(instance_options, options, self)
      end
    end
  end
end

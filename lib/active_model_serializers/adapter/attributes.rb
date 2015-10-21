module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def serializable_hash(options = nil)
        options = serialization_options(options)
        options[:fields] ||= instance_options[:fields]
        serializer.serializable_hash(instance_options, options, self)
      end
    end
  end
end

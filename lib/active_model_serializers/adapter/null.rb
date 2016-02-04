module ActiveModelSerializers
  module Adapter
    class Null < Base
      def serializable_hash(options = nil)
        {}
      end
    end
  end
end

module ActiveModelSerializers
  module Adapter
    class Null < Base
      # Since options param is not being used, underscored naming of the param
      def serializable_hash(_options = nil)
        {}
      end
    end
  end
end

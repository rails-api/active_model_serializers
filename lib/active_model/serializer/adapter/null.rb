module ActiveModel
  class Serializer
    module Adapter
      class Null < Base
        def serializable_hash(options = nil)
          {}
        end
      end
    end
  end
end

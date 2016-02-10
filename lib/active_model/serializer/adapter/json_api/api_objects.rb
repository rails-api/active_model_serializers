module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        module ApiObjects
          extend ActiveSupport::Autoload
          autoload :Relationship
          autoload :ResourceIdentifier
        end
      end
    end
  end
end

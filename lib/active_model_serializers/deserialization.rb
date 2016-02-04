module ActiveModelSerializers
  module Deserialization
    module_function

    def jsonapi_parse(*args)
      ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse(*args)
    end

    def jsonapi_parse!(*args)
      ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(*args)
    end
  end
end

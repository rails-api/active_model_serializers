module ActiveModel
  class Serializer
    module Adapter
      class FlatJson < JsonApi
        def serializable_hash(options = {})
          json_api_document = super(options)
          # convert keys to strings via to_json
          json_api_document = json_api_document.to_json
          # convert back to a hash (but now the keys are strings)
          json_api_document = JSON.parse(json_api_document)
          # deserialize
          Deserialization.parse(json_api_document, options)
        end
      end
    end
  end
end

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
          puts json_api_document
          puts json_api_document.keys
          puts json_api_document['included']
          puts 'ssssssssssssssssssssssss'
          Deserialization.parse(json_api_document, options)
        end
      end
    end
  end
end

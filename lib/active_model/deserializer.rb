module ActiveModel
  module Deserializer

    def self.included(base)
      base.wrap_parameters format: [:json]
    end

    def deserialize(params)
      # TODO deserializaion based on Adapter and Serializer
      params
    end

  end
end

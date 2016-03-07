module ActiveModel
  class Serializer
    # @deprecated Use ActiveModelSerializers::Adapter instead
    module Adapter
      class << self
        extend ActiveModelSerializers::Deprecate

        def self.delegate_and_deprecate(method)
          delegate method, to: ActiveModelSerializers::Adapter
          deprecate method, 'ActiveModelSerializers::Adapter.'
        end
        private_class_method :delegate_and_deprecate

        delegate_and_deprecate :create
        delegate_and_deprecate :adapter_class
        delegate_and_deprecate :adapter_map
        delegate_and_deprecate :adapters
        delegate_and_deprecate :register
        delegate_and_deprecate :lookup
      end

      require 'active_model/serializer/adapter/base'
      require 'active_model/serializer/adapter/null'
      require 'active_model/serializer/adapter/attributes'
      require 'active_model/serializer/adapter/json'
      require 'active_model/serializer/adapter/json_api'
    end
  end
end

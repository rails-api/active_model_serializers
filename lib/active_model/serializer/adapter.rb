module ActiveModel
  class Serializer
    # @deprecated Use ActiveModelSerializers::Adapter instead
    module Adapter
      class << self
        extend ActiveModelSerializers::Deprecate

        def create(resource, options = {})
          ActiveModelSerializers::Adapter.create(resource, options)
        end
        deprecate :create, 'ActiveModelSerializers::Adapter.'

        def adapter_class(adapter)
          ActiveModelSerializers::Adapter.adapter_class(adapter)
        end
        deprecate :adapter_class, 'ActiveModelSerializers::Adapter.'

        def adapter_map
          ActiveModelSerializers::Adapter.adapter_map
        end
        deprecate :adapter_map, 'ActiveModelSerializers::Adapter.'

        def adapters
          ActiveModelSerializers::Adapter.adapters
        end
        deprecate :adapters, 'ActiveModelSerializers::Adapter.'

        def register(name, klass = name)
          ActiveModelSerializers::Adapter.register(name, klass)
        end
        deprecate :register, 'ActiveModelSerializers::Adapter.'

        def lookup(adapter)
          ActiveModelSerializers::Adapter.lookup(adapter)
        end
        deprecate :lookup, 'ActiveModelSerializers::Adapter.'
      end

      require 'active_model/serializer/adapter/base'
      require 'active_model/serializer/adapter/null'
      require 'active_model/serializer/adapter/attributes'
      require 'active_model/serializer/adapter/json'
      require 'active_model/serializer/adapter/json_api'
    end
  end
end

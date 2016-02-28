module ActiveModel
  class Serializer
    # @deprecated Use ActiveModelSerializers::Adapter instead
    module Adapter
      class << self
        def create(resource, options = {})
          warn_deprecation
          ActiveModelSerializers::Adapter.create(resource, options)
        end

        def adapter_class(adapter)
          warn_deprecation
          ActiveModelSerializers::Adapter.adapter_class(adapter)
        end

        def adapter_map
          warn_deprecation
          ActiveModelSerializers::Adapter.adapter_map
        end

        def adapters
          warn_deprecation
          ActiveModelSerializers::Adapter.adapters
        end

        def register(name, klass = name)
          warn_deprecation
          ActiveModelSerializers::Adapter.register(name, klass)
        end

        def lookup(adapter)
          warn_deprecation
          ActiveModelSerializers::Adapter.lookup(adapter)
        end

        def warn_deprecation
          warn "Calling deprecated #{name} (#{__FILE__}) from #{caller[1..3].join(', ')}. Please use ActiveModelSerializers::Adapter"
        end
        private :warn_deprecation
      end

      require 'active_model/serializer/adapter/base'
      require 'active_model/serializer/adapter/null'
      require 'active_model/serializer/adapter/attributes'
      require 'active_model/serializer/adapter/json'
      require 'active_model/serializer/adapter/json_api'
    end
  end
end

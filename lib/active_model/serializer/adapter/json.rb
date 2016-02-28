require 'active_model_serializers/adapter/json'

module ActiveModel
  class Serializer
    module Adapter
      class Json < DelegateClass(ActiveModelSerializers::Adapter::Json)
        def initialize(serializer, options = {})
          warn "Calling deprecated #{self.class.name} (#{__FILE__}) from #{caller[0..2].join(', ')}. Please use #{self.class.name.sub('ActiveModel::Serializer', 'ActiveModelSerializers')}"
          super(ActiveModelSerializers::Adapter::Json.new(serializer, options))
        end
      end
    end
  end
end

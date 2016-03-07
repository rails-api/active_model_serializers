require 'active_model_serializers/adapter/null'

module ActiveModel
  class Serializer
    module Adapter
      class Null < DelegateClass(ActiveModelSerializers::Adapter::Null)
        def initialize(serializer, options = {})
          warn "Calling deprecated #{self.class.name} (#{__FILE__}) from #{caller[0..2].join(', ')}. Please use #{self.class.name.sub('ActiveModel::Serializer', 'ActiveModelSerializers')}"
          super(ActiveModelSerializers::Adapter::Null.new(serializer, options))
        end
      end
    end
  end
end

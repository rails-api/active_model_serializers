module ActiveModel
  class Serializer
    module Adapter
      class Base < DelegateClass(ActiveModelSerializers::Adapter::Base)
        def self.inherited(base)
          warn "Inheriting deprecated ActiveModel::Serializer::Adapter::Base in #{caller[0..2].join(', ')}. Please use ActiveModelSerializers::Adapter::Base"
          super
        end

        def initialize(serializer, options = {})
          super(ActiveModelSerializers::Adapter::Base.new(serializer, options))
        end
      end
    end
  end
end

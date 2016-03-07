module ActiveModel
  class Serializer
    module Adapter
      class Base < DelegateClass(ActiveModelSerializers::Adapter::Base)
        class << self
          extend ActiveModelSerializers::Deprecate
          deprecate :inherited, 'ActiveModelSerializers::Adapter::Base.'
        end

        def initialize(serializer, options = {})
          super(ActiveModelSerializers::Adapter::Base.new(serializer, options))
        end
      end
    end
  end
end

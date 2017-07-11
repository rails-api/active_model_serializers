module AMS
  module Delegatable
    KERNEL_METHOD_METHOD = ::Kernel.instance_method(:method)

    # delegate constant lookup to Object
    def const_missing(name)
      ::Object.const_get(name)
    end

    def self.extended(base)
      base.class_eval do
        # @!visibility private
        def send(*args)
          __send__(*args)
        end

        def method(method_name)
          AMS::Delegatable::KERNEL_METHOD_METHOD.bind(self).call(method_name)
        end

        private

        def method_missing(name, *args, &block)
          object.send(name, *args, &block)
        end

        def respond_to_missing?(name, include_private = false)
          object.respond_to?(name, include_private)
        end
      end
    end
  end
end

module AMS
  module Delegatable
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

        private

        def method_missing(name, *args, &block)
          object.send(name, *args, &block)
        end

        def respond_to_missing?(name, include_private = false)
          object.respond_to?(name, include_private)
        end

        const_set(:KERNEL_METHOD_METHOD, ::Kernel.instance_method(:method))
        def method_handle_for(method_name)
          KERNEL_METHOD_METHOD.bind(self).call(method_name)
        rescue NameError => original
          handle = self.method(method_name)
          raise original unless handle.is_a? Method
          handle
        end
        alias method method_handle_for
      end
    end
  end
end

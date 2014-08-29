module ActiveModel
  module Serializable
    module Utils
      extend self

      def _const_get(const)
        method = RUBY_VERSION >= '2.0' ? :const_get : :qualified_const_get
        Object.send method, const
      end
    end
  end
end
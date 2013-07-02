require 'active_support/core_ext/string/inflections'

module ActiveModel
  module SerializerSupport
    def active_model_serializer
      "#{self.class.name}Serializer".safe_constantize
    end

    alias read_attribute_for_serialization send
  end
end

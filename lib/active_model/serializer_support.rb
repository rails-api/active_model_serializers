# frozen_string_literal: true

module ActiveModel
  module SerializerSupport
    alias read_attribute_for_serialization send
  end
end

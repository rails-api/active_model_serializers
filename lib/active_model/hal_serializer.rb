require "active_model/serializer"
require "active_model/serializer/hal_link_utils"

module ActiveModel
  # Active Model HAL Serializer
  #
  # Provides a serializer implementation that allows you to move easily generate
  # valid HAL JSON for an given object. It's mostly like a normal Active Model
  # Serializer, but it has a +link+ helper and has some options pre-configured
  # to better suit HAL.
  class HalSerializer < ActiveModel::Serializer
    include HalLinkUtils

    self.root false

    # Returns a hash representation of the serializable
    # object without the root.
    def serializable_hash
      @node = links.any? ? super.merge(_links: links) : super
    end
  end
end

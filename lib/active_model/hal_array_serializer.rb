require 'active_model/array_serializer'
require 'active_model/serializer/hal_link_utils'

module ActiveModel
  class HalArraySerializer < ActiveModel::ArraySerializer
    include Serializer::HalLinkUtils

    self.root = false
    class_attribute :_embedded_resource_name

    class << self
      # Defines the root used on serialization. If false, disables the root.
      def embedded_resource_name(name)
        self._embedded_resource_name = name
      end
      alias_method :embedded_resource_name=, :embedded_resource_name
    end

    def serialize_object
      { _embedded: { embedded_resource_name => super } }.tap do |obj|
        obj[:_links] = links if links.any?
      end
    end

    def embedded_resource_name
      class_name = self.class.name.demodulize.underscore.sub(/_serializer$/, '').to_sym unless self.class.name.blank?

      if self._embedded_resource_name == true
        class_name
      else
        self._embedded_resource_name || class_name
      end
    end
  end
end

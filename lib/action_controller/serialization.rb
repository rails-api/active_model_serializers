require 'active_support/core_ext/class/attribute'
require 'active_model_serializers/serialization_context'

module ActionController
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    # Deprecated
    ADAPTER_OPTION_KEYS = ActiveModel::SerializableResource::ADAPTER_OPTION_KEYS

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user
    end

    def serialization_scope
      send(_serialization_scope) if _serialization_scope &&
        respond_to?(_serialization_scope, true)
    end

    def get_serializer(resource, options = {})
      if !use_adapter?
        warn 'ActionController::Serialization#use_adapter? has been removed. '\
          "Please pass 'adapter: false' or see ActiveSupport::SerializableResource.new"
        options[:adapter] = false
      end
      serializable_resource = ActiveModel::SerializableResource.new(resource, options)
      if serializable_resource.serializer?
        serializable_resource.serialization_scope ||= serialization_scope
        serializable_resource.serialization_scope_name = _serialization_scope
        begin
          # Necessary to ensure we have an adapter for the serializable resource
          # after it has been figured.
          # TODO: This logic should be less opaque and probably moved into the SerializableResource.
          serializable_resource.tap(&:adapter)
        rescue ActiveModel::Serializer::CollectionSerializer::NoSerializerError
          resource
        end
      else
        resource
      end
    end

    # Deprecated
    def use_adapter?
      true
    end

    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|
        options.fetch(:serialization_context) { options[:serialization_context] = ActiveModelSerializers::SerializationContext.new(request) }
        serializable_resource = get_serializer(resource, options)
        super(serializable_resource, options)
      end
    end
  end
end

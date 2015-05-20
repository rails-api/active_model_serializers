require 'active_support/core_ext/class/attribute'

module ActionController
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    ADAPTER_OPTION_KEYS = [:include, :fields, :root, :adapter]

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user
    end

    def serialization_scope
      send(_serialization_scope) if _serialization_scope &&
        respond_to?(_serialization_scope, true)
    end

    def get_serializer(resource)
      @_serializer ||= @_serializer_opts.delete(:serializer)
      @_serializer ||= ActiveModel::Serializer.serializer_for(resource)

      if @_serializer_opts.key?(:each_serializer)
        @_serializer_opts[:serializer] = @_serializer_opts.delete(:each_serializer)
      end

      @_serializer
    end

    def use_adapter?
      !(@_adapter_opts.key?(:adapter) && !@_adapter_opts[:adapter])
    end

    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|
        @_adapter_opts, @_serializer_opts =
          options.partition { |k, _| ADAPTER_OPTION_KEYS.include? k }.map { |h| Hash[h] }

        if use_adapter? && (serializer = get_serializer(resource))

          @_serializer_opts[:scope] ||= serialization_scope
          @_serializer_opts[:scope_name] = _serialization_scope

          # omg hax
          object = serializer.new(resource, @_serializer_opts)
          adapter = ActiveModel::Serializer::Adapter.create(object, @_adapter_opts)
          super(adapter, options)
        else
          super(resource, options)
        end
      end
    end

    def rescue_with_handler(exception)
      @_serializer = nil
      @_serializer_opts = nil
      @_adapter_opts = nil

      super(exception)
    end

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end
  end
end

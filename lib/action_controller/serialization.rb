require 'active_support/core_ext/class/attribute'

module ActionController
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    ADAPTER_OPTION_KEYS = [:include, :root]

    def get_serializer(resource, options)
      @_serializer ||= options.delete(:serializer)
      @_serializer ||= ActiveModel::Serializer.serializer_for(resource)

      if options.key?(:each_serializer)
        options[:serializer] = options.delete(:each_serializer)
      end

      @_serializer
    end

    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|

        adapter_opts, serializer_opts =
          options.partition { |k, _| ADAPTER_OPTION_KEYS.include? k }.map { |h| Hash[h] }

        if (serializer = get_serializer(resource, serializer_opts))
          # omg hax
          object = serializer.new(resource, serializer_opts)
          adapter = ActiveModel::Serializer.adapter.new(object, adapter_opts)
          super(adapter, options)
        else
          super(resource, options)
        end
      end
    end
  end
end

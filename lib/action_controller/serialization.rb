require 'active_support/core_ext/class/attribute'

module ActionController
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    ADAPTER_OPTION_KEYS = [:include, :root]

    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|
        serializer = ActiveModel::Serializer.serializer_for(resource)

        if serializer
          adapter_opts, serializer_opts =
            options.partition { |k, _| ADAPTER_OPTION_KEYS.include? k }
          # omg hax
          object = serializer.new(resource, Hash[serializer_opts])
          adapter = ActiveModel::Serializer.adapter.new(object, Hash[adapter_opts])
          super(adapter, options)
        else
          super(resource, options)
        end
      end
    end
  end
end

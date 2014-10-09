require 'active_support/core_ext/class/attribute'

module ActionController
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|
        serializer = ActiveModel::Serializer.serializer_for(resource)

        if serializer
          # omg hax
          object = serializer.new(resource)
          adapter = ActiveModel::Serializer.adapter.new(object)

          super(adapter, options)
        else
          super(resource, options)
        end
      end
    end
  end
end


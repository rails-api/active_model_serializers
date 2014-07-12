require 'active_support/core_ext/class/attribute'

module ActionController
  # Action Controller Serialization
  #
  # Overrides render :json to check if the given object implements +active_model_serializer+
  # as a method. If so, use the returned serializer instead of calling +to_json+ on the object.
  #
  # This module also provides a serialization_scope method that allows you to configure the
  # +serialization_scope+ of the serializer. Most apps will likely set the +serialization_scope+
  # to the current user:
  #
  #    class ApplicationController < ActionController::Base
  #      serialization_scope :current_user
  #    end
  #
  # If you need more complex scope rules, you can simply override the serialization_scope:
  #
  #    class ApplicationController < ActionController::Base
  #      private
  #
  #      def serialization_scope
  #        current_user
  #      end
  #    end
  #
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers
    include ActiveModel::Serializers::Xml

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user
    end

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end

    [:json, :xml].each do |format|
      define_method("_render_option_#{format}") do |resource, options|
        serializer = build_serializer(resource, options)

        if serializer
          super(serializer, options)
        else
          super(resource, options)
        end
      end
    end

    private

    def default_serializer_options
      {}
    end

    def serialization_scope
      _serialization_scope = self.class._serialization_scope
      send(_serialization_scope) if _serialization_scope && respond_to?(_serialization_scope, true)
    end

    def build_serializer(resource, options = {})
      options = default_serializer_options.merge(options)

      if serializer = options.fetch(:serializer, ActiveModel::Serializer.serializer_for(resource))
        options[:scope] = serialization_scope unless options.has_key?(:scope)
        options[:resource_name] = controller_name if resource.respond_to?(:to_ary)

        serializer.new(resource, options)
      end
    end
  end
end

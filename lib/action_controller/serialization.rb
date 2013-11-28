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
  # If you need to disable serialization on a specific controller, place "disable_controller" in 
  # your controller to disable any serialization from ActiveModel::Serializer. Note that this will
  # disable serialization even if you have a serializer present.
  #
  #    class UserController < ApplicationController
  #      disable_serialization
  #
  #      def show
  #        render json: User.find(params[:id)
  #      end
  #    end
  
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    included do
      class_attribute :_serialization_scope, :should_serialize
      self._serialization_scope = :current_user
      self.should_serialize = true
    end

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
      def disable_serialization
        self.should_serialize = false
      end
    end

    def _render_option_json(resource, options)
      serializer = build_json_serializer(resource, options)

      if serializer
        super(serializer, options)
      else
        super
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

    def build_json_serializer(resource, options)
      return if !self.class.should_serialize
      options = default_serializer_options.merge(options || {})

      if serializer = options.fetch(:serializer, ActiveModel::Serializer.serializer_for(resource))
        options[:scope] = serialization_scope unless options.has_key?(:scope)
        options[:resource_name] = self.controller_name if resource.respond_to?(:to_ary)

        serializer.new(resource, options)
      end
    end
  end
end

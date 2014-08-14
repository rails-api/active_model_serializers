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

    class << self
      attr_accessor :enabled
    end
    self.enabled = true

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user
    end

    def serialization_scope
      send(_serialization_scope) if _serialization_scope && respond_to?(_serialization_scope, true)
    end

    def default_serializer_options
    end

    def _render_option_json(resource, options)
      json = ActiveModel::Serializer.build_json(self, resource, options)

      if json
        super(json, options)
      else
        super
      end
    end

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end
  end
end

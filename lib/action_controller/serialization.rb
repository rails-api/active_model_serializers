module ActionController
  # Action Controller Serialization
  #
  # Overrides render :json to check if the given object implements +active_model_serializer+
  # as a method. If so, use the returned serializer instead of calling +to_json+ in the object.
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

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user

      unless self.respond_to?(:responder=)
        include ActionController::MimeResponds
      end

      self.responder = ActiveModel::Serializer::Responder
      self.respond_to :json

      unless ActiveModel::Serializer.use_default_render_json
        self.send(:include, RenderJsonOverride)
      end
    end

    def serialization_scope
      send(_serialization_scope) if _serialization_scope && respond_to?(_serialization_scope)
    end

    def default_serializer_options
    end

    module RenderJsonOverride
      def _render_option_json(json, options)
        options = default_serializer_options.merge(options) if default_serializer_options

        serializer = options.delete(:serializer) ||
          (json.respond_to?(:active_model_serializer) && json.active_model_serializer)

        if json.respond_to?(:to_ary)
          unless serializer <= ActiveModel::ArraySerializer
            raise ArgumentError.new("#{serializer.name} is not an ArraySerializer. " +
               "You may want to use the :each_serializer option instead.")
          end

          if options[:root] != false && serializer.root != false
            # default root element for arrays is serializer's root or the controller name
            # the serializer for an Array is ActiveModel::ArraySerializer
            options[:root] ||= serializer.root || controller_name
          end
        end

        if serializer
          options[:scope] = serialization_scope unless options.has_key?(:scope)
          options[:url_options] = url_options
          json = serializer.new(json, options)
        end
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

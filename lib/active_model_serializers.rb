require "active_model"
require "active_model/serializer"

ActiveModel::Serialization.class_eval do
  extend ActiveSupport::Concern

  module ClassMethods #:nodoc:
    def active_model_serializer
      return @active_model_serializer if defined?(@active_model_serializer)
      @active_model_serializer = "#{self.name}Serializer".safe_constantize
    end
  end

  # Returns a model serializer for this object considering its namespace.
  def active_model_serializer
    self.class.active_model_serializer
  end
end

require "action_controller"

module ActionController
  autoload :Serialization, "action_controller/serialization"
end

ActiveSupport.on_load(:action_controller) do
  include ::ActionController::Serialization
end
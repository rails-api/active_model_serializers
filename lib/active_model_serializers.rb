require "active_model"
require "active_model/serializer"

ActiveModel::Serialization.class_eval do
  extend ActiveSupport::Concern

  module ClassMethods #:nodoc:
    def active_model_serializer
      return @active_model_serializer if defined?(@active_model_serializer)

      # Use safe constantize when Rails 3.2 is out
      begin
        @active_model_serializer = "#{self.name}Serializer".constantize
      rescue NameError => e
        raise unless e.message =~ /uninitialized constant$/ && e.name.to_s == "#{self.name}Serializer"
      end
    end
  end

  # Returns a model serializer for this object considering its namespace.
  def active_model_serializer
    self.class.active_model_serializer
  end
end

begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end
rescue LoadError => ex
  # rails on installed, continuing
end

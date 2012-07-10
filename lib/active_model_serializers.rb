require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/notifications"
require "active_model"
require "active_model/serializer"

if defined?(Rails)
  module ActiveModel
    class Railtie < Rails::Railtie
      generators do |app|
        app ||= Rails.application # Rails 3.0.x does not yield `app`

        Rails::Generators.configure!(app.config.generators)
        require "generators/resource_override"
      end

      initializer "include_routes.active_model_serializer" do |app|
        ActiveSupport.on_load(:active_model_serializers) do
          include app.routes.url_helpers
        end
      end
    end
  end
end

module ActiveModel::SerializerSupport
  extend ActiveSupport::Concern

  module ClassMethods #:nodoc:
    if "".respond_to?(:safe_constantize)
      def active_model_serializer
        @active_model_serializer ||= "#{self.name}Serializer".safe_constantize
      end
    else
      def active_model_serializer
        return @active_model_serializer if defined?(@active_model_serializer)

        begin
          @active_model_serializer = "#{self.name}Serializer".constantize
        rescue NameError => e
          raise unless e.message =~ /uninitialized constant/
        end
      end
    end
  end

  # Returns a model serializer for this object considering its namespace.
  def active_model_serializer
    self.class.active_model_serializer
  end

  alias :read_attribute_for_serialization :send
end

ActiveSupport.on_load(:active_record) do
  include ActiveModel::SerializerSupport
end

module ActiveModel::ArraySerializerSupport
  def active_model_serializer
    ActiveModel::ArraySerializer
  end
end

Array.send(:include, ActiveModel::ArraySerializerSupport)

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.send(:include, ActiveModel::ArraySerializerSupport)
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

ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModel::Serializer)

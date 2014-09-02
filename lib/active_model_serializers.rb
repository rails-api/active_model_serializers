require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/notifications"
require "active_model"
require "active_model/array_serializer"
require "active_model/serializer"
require "active_model/serializer/associations"
require "set"

if defined?(Rails)
  module ActiveModel
    class Railtie < Rails::Railtie
      generators do |app|
        app ||= Rails.application # Rails 3.0.x does not yield `app`

        Rails::Generators.configure!(app.config.generators)
        Rails::Generators.hidden_namespaces.uniq!
        require_relative "generators/resource_override"
      end

      initializer "include_routes.active_model_serializer" do |app|
        ActiveSupport.on_load(:active_model_serializers) do
          include app.routes.url_helpers
        end
      end

      initializer "caching.active_model_serializer" do |app|
        ActiveModel::Serializer.perform_caching = app.config.action_controller.perform_caching
        ActiveModel::ArraySerializer.perform_caching = app.config.action_controller.perform_caching

        ActiveModel::Serializer.cache = Rails.cache
        ActiveModel::ArraySerializer.cache = Rails.cache
      end
    end
  end
end

module ActiveModel::SerializerSupport
  extend ActiveSupport::Concern

  module ClassMethods #:nodoc:
    if "".respond_to?(:safe_constantize)
      def active_model_serializer
        "#{self.name}Serializer".safe_constantize
      end
    else
      def active_model_serializer
        begin
          "#{self.name}Serializer".constantize
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

module ActiveModel::ArraySerializerSupport
  def active_model_serializer
    ActiveModel::ArraySerializer
  end
end

Array.send(:include, ActiveModel::ArraySerializerSupport)
Set.send(:include, ActiveModel::ArraySerializerSupport)

{
  :active_record => 'ActiveRecord::Relation',
  :mongoid => 'Mongoid::Criteria'
}.each do |orm, rel_class|
  ActiveSupport.on_load(orm) do
    include ActiveModel::SerializerSupport
    rel_class.constantize.send(:include, ActiveModel::ArraySerializerSupport)
  end
end

begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:after_initialize) do
    if ::ActionController::Serialization.enabled
      ActionController::Base.send(:include, ::ActionController::Serialization)
    end
  end
rescue LoadError => ex
  # rails on installed, continuing
end

ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModel::Serializer)

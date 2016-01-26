require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'
require 'action_controller/serialization'

module ActiveModelSerializers
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveModel::Serializer.serializers_cache.clear
    end

    initializer 'active_model_serializers.action_controller' do
      ActiveSupport.on_load(:action_controller) do
        include(::ActionController::Serialization)
      end
    end

    # This hook is run after the action_controller railtie has set the configuration
    # based on the *environment* configuration and before any config/initializers are run
    # and also before eager_loading (if enabled).
    initializer 'active_model_serializers.set_configs', :after => 'action_controller.set_configs' do
      ActiveModelSerializers.logger = Rails.configuration.action_controller.logger
      ActiveModelSerializers.config.cache_store     = Rails.configuration.action_controller.cache_store
      ActiveModelSerializers.config.perform_caching = Rails.configuration.action_controller.perform_caching
    end

    generators do |app|
      Rails::Generators.configure!(app.config.generators)
      Rails::Generators.hidden_namespaces.uniq!
      require 'generators/rails/resource_override'
    end

    if Rails.env.test?
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Schema)
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Serializer)
    end
  end
end

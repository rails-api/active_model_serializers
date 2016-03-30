require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'
require 'action_controller/serialization'

module ActiveModelSerializers
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveModel::Serializer.serializers_cache.clear
    end

    initializer 'active_model_serializers.prepare_serialization_context' do
      SerializationContext.url_helpers = Rails.application.routes.url_helpers
      SerializationContext.default_url_options = Rails.application.routes.default_url_options
    end

    # This hook is run after the action_controller railtie has set the configuration
    # based on the *environment* configuration and before any config/initializers are run
    # and also before eager_loading (if enabled).
    initializer 'active_model_serializers.set_configs', :after => 'action_controller.set_configs' do
      ActiveModelSerializers.logger = Rails.configuration.action_controller.logger
      ActiveModelSerializers.config.perform_caching = Rails.configuration.action_controller.perform_caching
      # We want this hook to run after the config has been set, even if ActionController has already loaded.
      ActiveSupport.on_load(:action_controller) do
        ActiveModelSerializers.config.cache_store = cache_store
        # Only include controller mixin when enabled
        # https://github.com/rails-api/active_model_serializers/issues/1500
        # https://github.com/rails-api/active_model_serializers/pull/592
        # Rails.configuration.action_controller.render_json_with_active_model_serializers
        include ::ActionController::Serialization if ::ActionController::Serialization.enabled
      end
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

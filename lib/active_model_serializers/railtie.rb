require 'rails/railtie'

module ActiveModelSerializers
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveModel::Serializer.serializers_cache.clear
    end

    initializer 'active_model_serializers.action_controller' do
      ActiveSupport.on_load(:action_controller) do
        ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModelSerializers)
        include ::ActionController::Serialization
      end
    end

    initializer 'active_model_serializers.logger' do
      ActiveSupport.on_load(:active_model_serializers) do
        self.logger = ActionController::Base.logger
      end
    end

    initializer 'active_model_serializers.caching' do
      ActiveSupport.on_load(:action_controller) do
        ActiveModelSerializers.config.cache_store     = ActionController::Base.cache_store
        ActiveModelSerializers.config.perform_caching = Rails.configuration.action_controller.perform_caching
      end
    end

    generators do
      require 'generators/rails/resource_override'
    end

    if Rails.env.test?
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Schema)
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Serializer)
    end
  end
end

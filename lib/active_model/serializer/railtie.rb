require 'rails/railtie'

module ActiveModel
  class Railtie < Rails::Railtie
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

    initializer 'generators' do |app|
      app.load_generators
      require 'generators/serializer/resource_override'
    end

    if Rails.env.test?
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Schema)
    end
  end
end

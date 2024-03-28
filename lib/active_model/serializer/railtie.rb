require "rails/railtie"

module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'generators' do |app|
      app.load_generators
      require 'active_model/serializer/generators/serializer/serializer_generator'
      require 'active_model/serializer/generators/serializer/scaffold_controller_generator'
      require 'active_model/serializer/generators/resource_override'
    end

    initializer 'include_routes.active_model_serializer' do |app|
      ActiveSupport.on_load(:active_model_serializers) do
        include app.routes.url_helpers
      end
    end

    config.to_prepare do
      ActiveModel::Serializer.serializers_cache.clear
    end
  end
end

ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModel::Serializer)

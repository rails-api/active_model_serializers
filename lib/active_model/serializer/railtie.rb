require 'rails/railtie'
module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'active_model_serializers.logger' do
      ActiveSupport.on_load(:action_controller) do
        ActiveModelSerializers.logger = ActionController::Base.logger
      end
    end

    initializer 'active_model_serializers.url_helpers' do
      ActiveSupport.on_load(:action_controller) do
        ActiveModelSerializers.url_helpers = Module.new do
          include Rails.application.routes.url_helpers

          def self.default_url_options
            ActionController::Base.default_url_options
          end
        end
      end
    end

    initializer 'generators' do |app|
      app.load_generators
      require 'generators/serializer/resource_override'
    end
  end
end

require 'rails/railtie'
module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'active_model_serializers.logger' do
      ActiveSupport.on_load(:active_model_serializers) { self.logger ||= Rails.logger }
    end

    initializer 'generators' do |app|
      app.load_generators
      require 'generators/serializer/resource_override'
    end
  end
end

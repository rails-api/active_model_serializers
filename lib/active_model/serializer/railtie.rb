module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'generators' do |app|
      app.load_generators
      require 'active_model/serializer/generators/serializer/serializer_generator'
      require 'active_model/serializer/generators/serializer/scaffold_controller_generator'
      require 'active_model/serializer/generators/resource_override'
    end

    initializer 'include_url_helpers' do |app|
      ActiveSupport.on_load(:active_model_serializers) do
        include app.routes.url_helpers
      end
    end
  end
end

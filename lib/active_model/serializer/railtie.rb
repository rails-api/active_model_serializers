module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'active_model_serializers.setup_generators' do |app|
      app.load_generators
      require 'active_model/serializer/generators/serializer/serializer_generator'
      require 'active_model/serializer/generators/serializer/scaffold_controller_generator'
      require 'active_model/serializer/generators/resource_override'
    end

    initializer 'active_model_serializers.include_url_helpers' do |app|
      ActiveSupport.on_load(:active_model_serializers) do
        ::ActiveModel::Serializer::UrlGenerator.send :include, app.routes.url_helpers
      end
    end
  end
end

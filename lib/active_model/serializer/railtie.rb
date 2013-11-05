module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'generators' do |app|
      require 'rails/generators'
      require 'active_model/serializer/generators/serializer/serializer_generator'
      require 'active_model/serializer/generators/serializer/scaffold_controller_generator'
      Rails::Generators.configure!(app.config.generators)
      require 'active_model/serializer/generators/resource_override'
    end
  end
end

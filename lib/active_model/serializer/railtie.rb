module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'generators' do |app|
      app.load_generators
      require 'active_model/serializer/generators/serializer/serializer_generator'
      require 'active_model/serializer/generators/serializer/scaffold_controller_generator'
      require 'active_model/serializer/generators/resource_override'
    end
  end
end

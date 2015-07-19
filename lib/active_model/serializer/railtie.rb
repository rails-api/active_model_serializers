require 'rails/railtie'
module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'generators' do |app|
      app.load_generators
      require 'generators/serializer/resource_override'
    end
  end
end

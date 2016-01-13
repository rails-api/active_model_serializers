module ActiveModelSerializers
  class Engine < ::Rails::Engine
    isolate_namespace ActiveModelSerializers
    config.generators.api_only = true
  end
end

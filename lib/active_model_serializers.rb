require 'active_model'
require 'active_model/serializer'
require 'active_model/serializer_support'
require 'active_model/serializer/version'
require 'active_model/serializer/railtie' if defined?(Rails)

begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end

  if defined?(RSpec)
    require 'active_model/serializer/integrations/rspec'
  end
rescue LoadError
  # rails not installed, continuing
end

require "active_model"
require "active_model/serializer/version"
require "active_model/serializer"
require "active_model/serializer/adapter/simple_adapter"

begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end
rescue LoadError
  # rails not installed, continuing
end

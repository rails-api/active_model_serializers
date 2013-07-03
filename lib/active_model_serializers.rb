require 'newbase/active_model/serializer'
require 'newbase/active_model/serializer_support'

begin
  require 'action_controller'
  require 'newbase/action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end
rescue LoadError
  # rails not installed, continuing
end

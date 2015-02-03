require "active_model"
require "active_model/serializer/version"
require "active_model/serializer"
require "active_model/serializer/fieldset"
require "active_model/serializers"

include ActiveModel::Serializers
begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end
rescue LoadError
  # rails not installed, continuing
end

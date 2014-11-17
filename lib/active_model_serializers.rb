require "active_model"
require "active_model/serializer/version"
require "active_model/serializer"

begin
  require 'action_controller'
  require 'action_controller/serialization'
rescue LoadError
  # rails not installed, continuing
end

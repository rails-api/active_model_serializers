module ActiveModelSerializers
  module_function

  def silence_warnings
    verbose = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = verbose
  end
end

require 'active_model'
require 'action_controller'

require 'active_model/serializer'
require 'active_model/serializable_resource'
require 'active_model/serializer/version'

require 'action_controller/serialization'
ActiveSupport.on_load(:action_controller) do
  include ::ActionController::Serialization
  ActionDispatch::Reloader.to_prepare do
    ActiveModel::Serializer.serializers_cache.clear
  end
end

require 'active_model/serializer/railtie'

require 'active_model'
require 'active_support'
require 'action_controller'
require 'action_controller/railtie'
module ActiveModelSerializers
  extend ActiveSupport::Autoload
  autoload :Model
  autoload :Callbacks
  autoload :Deserialization
  autoload :Logging
  autoload :Test

  mattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) }

  def self.config
    ActiveModel::Serializer.config
  end

  require 'active_model/serializer/version'
  require 'active_model/serializer'
  require 'active_model_serializers/railtie'
  require 'active_model/serializable_resource'
  require 'action_controller/serialization'
end

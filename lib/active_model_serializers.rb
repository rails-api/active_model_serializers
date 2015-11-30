require 'active_model'
require 'active_support'
require 'action_controller'
require 'action_controller/railtie'
require 'active_model/serializer/version'
require 'active_model/serializer'
require 'active_model_serializers/railtie'
module ActiveModelSerializers
  extend ActiveSupport::Autoload
  autoload :Model
  autoload :Callbacks
  autoload :Logging

  require 'active_model/serializable_resource'
  require 'action_controller/serialization'

  mattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) }

  def self.config
    ActiveModel::Serializer.config
  end

  extend ActiveSupport::Autoload
  autoload :Model
  autoload :Callbacks
  autoload :Deserialization
  autoload :Logging
  autoload :Test
end

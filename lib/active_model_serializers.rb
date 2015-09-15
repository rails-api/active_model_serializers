require 'logger'
require 'active_model'
require "active_support/railtie"
require 'action_controller'
require "action_controller/railtie"
module ActiveModelSerializers
  mattr_accessor :logger
  self.logger = Rails.logger || Logger.new(IO::NULL)

  module_function

  def silence_warnings
    verbose = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = verbose
  end
end

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

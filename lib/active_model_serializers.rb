require 'active_model'
require 'active_support'
require 'active_support/core_ext/object/with_options'
module ActiveModelSerializers
  extend ActiveSupport::Autoload
  autoload :Model
  autoload :Callbacks
  autoload :Deserialization
  autoload :Logging
  autoload :Test

  class << self; attr_accessor :logger; end
  self.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))

  def self.config
    ActiveModel::Serializer.config
  end

  require 'active_model/serializer/version'
  require 'active_model/serializer'
  require 'active_model/serializable_resource'
  require 'active_model_serializers/railtie' if defined?(::Rails)
end

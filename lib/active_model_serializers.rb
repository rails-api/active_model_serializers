require 'active_model'
require 'active_support'
require 'action_controller'
require 'action_controller/railtie'
module ActiveModelSerializers
  mattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) }

  def self.config
    ActiveModel::Serializer.config
  end

  extend ActiveSupport::Autoload
  autoload :Model
  autoload :Callbacks
  autoload :Logging
  autoload :Test

  module_function

  # @note
  #   ```ruby
  #   private
  #
  #   attr_reader :resource, :adapter_opts, :serializer_opts
  #   ```
  #
  #   Will generate a warning, though it shouldn't.
  #   There's a bug in Ruby for this: https://bugs.ruby-lang.org/issues/10967
  #
  #   We can use +ActiveModelSerializers.silence_warnings+ as a
  #   'safety valve' for unfixable or not-worth-fixing warnings,
  #   and keep our app warning-free.
  #
  #   ```ruby
  #   private
  #
  #   ActiveModelSerializers.silence_warnings do
  #     attr_reader :resource, :adapter_opts, :serializer_opts
  #   end
  #   ```
  #
  #   or, as specific stopgap, define the attrs in the protected scope.
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
  ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModelSerializers)
  include ::ActionController::Serialization
  ActionDispatch::Reloader.to_prepare do
    ActiveModel::Serializer.serializers_cache.clear
  end
end

require 'active_model/serializer/railtie'

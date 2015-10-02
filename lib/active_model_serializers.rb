require 'logger'
require 'active_model'
require 'active_support'
require 'action_controller'
require 'action_controller/railtie'
module ActiveModelSerializers
  mattr_accessor :logger
  self.logger = Rails.logger || Logger.new(IO::NULL)

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

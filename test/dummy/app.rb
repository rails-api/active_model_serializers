# https://github.com/rails-api/active_model_serializers/pull/872
# approx ref 792fb8a9053f8db3c562dae4f40907a582dd1720 to test against
require 'bundler/setup'

require 'rails'
require 'active_model'
require 'active_support'
require 'active_support/json'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
abort "Rails application already defined: #{Rails.application.class}" if Rails.application

class NullLogger < Logger
  def initialize(*_args)
  end

  def add(*_args, &_block)
  end
end
class DummyLogger < ActiveSupport::Logger
  def initialize
    @file = StringIO.new
    super(@file)
  end

  def messages
    @file.rewind
    @file.read
  end
end
# ref: https://gist.github.com/bf4/8744473
class DummyApp < Rails::Application
  # CONFIG: CACHE_ON={on,off}
  config.action_controller.perform_caching = ENV['CACHE_ON'] != 'off'
  config.action_controller.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

  # Set up production configuration
  config.eager_load = true
  config.cache_classes = true

  config.active_support.test_order = :random
  config.secret_token = '1234'
  config.secret_key_base = 'abc123'
  config.logger = NullLogger.new
end

require 'active_model_serializers'

# Initialize app before any serializers are defined, for sanity's sake.
# Otherwise, you have to manually set perform caching.
#
# Details:
#
# 1. Upon load, when AMS.config.perform_caching is true,
#    serializers inherit the cache store from ActiveModelSerializers.config.cache_store
# 1. If the serializers are loaded before Rails is initialized (`Rails.application.initialize!`),
#    these values are nil, and are not applied to the already loaded serializers
# 1. If Rails is initialized before any serializers are loaded, then the configs are set,
#    and are used when serializers are loaded
# 1. In either case, `ActiveModelSerializers.config.cache_store`, and
#    `ActiveModelSerializers.config.perform_caching` can be set at any time before the serializers
#    are loaded,
#    e.g.  `ActiveModel::Serializer.config.cache_store ||=
#      ActiveSupport::Cache.lookup_store(ActionController::Base.cache_store ||
#      Rails.cache || :memory_store)`
#    and `ActiveModelSerializers.config.perform_caching = true`
# 1. If the serializers are loaded before Rails is initialized, then,
#    you can set the `_cache` store directly on the serializers.
#    `ActiveModel::Serializer._cache ||=
#      ActiveSupport::Cache.lookup_store(ActionController::Base.cache_store ||
#      Rails.cache || :memory_store`
#    is sufficient.
#    Setting `_cache` to a truthy value will cause the CachedSerializer
#    to consider it cached, which will apply to all serializers (bug? :bug: )
#
# This happens, in part, because the cache store is set for a serializer
# when `cache` is called, and cache is usually called when the serializer is defined.
#
# So, there's now a 'workaround', something to debug, and a starting point.
Rails.application.initialize!

# HACK: Serializer::cache depends on the ActionController-dependent configs being set.
ActiveSupport.on_load(:action_controller) do
  require_relative 'fixtures'
end
require_relative 'controllers'

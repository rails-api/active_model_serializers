require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'
require 'action_controller/serialization'

module ActiveModelSerializers
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveModel::Serializer.serializers_cache.clear
    end

    initializer 'active_model_serializers.action_controller' do
      ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModelSerializers)
      ActionController::Base.send(:include, ::ActionController::Serialization)
    end

    initializer 'active_model_serializers.logger' do
      ActiveSupport.on_load(:active_model_serializers) do
        self.logger = ActionController::Base.logger
      end
    end

    # To be useful, this hook must run after Rails has initialized,
    # BUT before any serializers are loaded.
    # Otherwise, the call to 'cache' won't find `cache_store` or `perform_caching`
    # defined, and serializer's `_cache_store` will be nil.
    # IF the load order cannot be changed, then in each serializer that that defines a `cache`,
    # manually specify e.g. `PostSerializer._cache_store = Rails.cache` any time
    # before the serializer is used.  (Even though `ActiveModel::Serializer._cache_store` is
    # inheritable, we don't want to set it on `ActiveModel::Serializer` directly unless
    # we want *every* serializer to be considered cacheable, regardless of specifying
    # `cache # some options` in a serializer or not.
    initializer 'active_model_serializers.caching' => :after_initialize do
      ActiveModelSerializers.config.cache_store     = ActionController::Base.cache_store
      ActiveModelSerializers.config.perform_caching = Rails.configuration.action_controller.perform_caching
    end

    generators do
      require 'generators/rails/resource_override'
    end

    if Rails.env.test?
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Schema)
      ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Serializer)
    end
  end
end

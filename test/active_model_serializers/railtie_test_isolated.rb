# Execute this test in isolation
require 'support/isolated_unit'

class RailtieTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  class WithRails < RailtieTest
    setup do
      require 'rails'
      require 'active_model_serializers'
      make_basic_app
    end

    test 'mixes ActionController::Serialization into ActionController::Base' do
      assert ActionController.const_defined?(:Serialization),
        "ActionController::Serialization should be defined, but isn't"
      assert ::ActionController::Base.included_modules.include?(::ActionController::Serialization),
        "ActionController::Serialization should be included in ActionController::Base, but isn't"
    end

    test 'prepares url_helpers for SerializationContext' do
      assert ActiveModelSerializers::SerializationContext.url_helpers.respond_to? :url_for
      assert_equal Rails.application.routes.default_url_options,
        ActiveModelSerializers::SerializationContext.default_url_options
    end

    test 'sets the ActiveModelSerializers.logger to Rails.logger' do
      refute_nil Rails.logger
      refute_nil ActiveModelSerializers.logger
      assert_equal Rails.logger, ActiveModelSerializers.logger
    end

    test 'it is configured for caching' do
      assert_equal ActionController::Base.cache_store, ActiveModelSerializers.config.cache_store
      assert_equal Rails.configuration.action_controller.perform_caching, ActiveModelSerializers.config.perform_caching
    end
  end

  class WithoutRails < RailtieTest
    setup do
      require 'active_model_serializers'
      make_basic_app
    end

    test 'does not mix ActionController::Serialization into ActionController::Base' do
      refute ActionController.const_defined?(:Serialization),
        'ActionController::Serialization should not be defined, but is'
    end

    test 'has its own logger at ActiveModelSerializers.logger' do
      refute_nil Rails.logger
      refute_nil ActiveModelSerializers.logger
      refute_equal Rails.logger, ActiveModelSerializers.logger
    end

    test 'it is not configured for caching' do
      refute_nil ActionController::Base.cache_store
      assert_nil ActiveModelSerializers.config.cache_store
      refute Rails.configuration.action_controller.perform_caching
      refute ActiveModelSerializers.config.perform_caching
    end
  end
end

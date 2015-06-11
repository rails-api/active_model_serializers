require 'bundler/setup'

require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
require 'active_support/json'
require 'minitest/autorun'
require 'fileutils'
# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

require 'active_model_serializers'

class Foo < Rails::Application
  if Rails::VERSION::MAJOR >= 4
    config.eager_load = false
    config.secret_key_base = 'abc123'
    config.action_controller.perform_caching = true
    config.active_support.test_order = :random
    config.logger = Logger.new(nil)
    ActionController::Base.cache_store = :memory_store
  end
end
FileUtils.mkdir_p(File.expand_path('../../tmp/cache', __FILE__))
Foo.initialize!

require 'fixtures/poro'

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    get ':controller(/:action(/:id))'
    get ':controller(/:action)'
  end

  ActionController::Base.send :include, Routes.url_helpers
end

ActionController::TestCase.class_eval do
  def setup
    @routes = TestHelper::Routes
  end
end

require 'bundler/setup'

require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
require 'active_support/json'
require 'minitest/autorun'
# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class Foo < Rails::Application
  if Rails.version.to_s.start_with? '4'
    config.action_controller.perform_caching = true
    config.active_support.test_order         = :random
    ActionController::Base.cache_store       = :memory_store
  end
end

require "active_model_serializers"

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

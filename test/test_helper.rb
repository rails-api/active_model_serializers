require 'bundler/setup'
require 'minitest/autorun'
require 'active_model_serializers'
require 'fixtures/poro'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    get ':controller(/:action(/:id))'
    get ':controller(/:action)'
  end

  ActionController::Base.send :include, Routes.url_helpers
  ActionController::Base.send :include, ActionController::Serialization
end

ActionController::TestCase.class_eval do
  def setup
    @routes = TestHelper::Routes
  end
end

Minitest::Test.class_eval do
  def before_setup
    @original_configurations = {}

    ActiveModel::Serializer.setup do |config|
      config.each do |k, v|
        @original_configurations[k] = v
      end
    end
  end

  def after_teardown
    ActiveModel::Serializer.setup do |config|
      config.clear
      @original_configurations.each do |k, v|
        config.send("#{k}=", v)
      end
    end
  end
end

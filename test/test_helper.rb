require 'bundler/setup'
require 'minitest/autorun'
require 'active_model_serializers'
require 'fixtures/poro'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

module DefineTestSerializerClass
  def define_test_serializer_class(name = "TestSerializer#{SecureRandom.hex(32)}", base = ActiveModel::Serializer, &block)
    serializer = Class.new(base, &block)
    Object.const_set(name, serializer)
  end
end

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    get ':controller(/:action(/:id))'
    get ':controller(/:action)'
  end

  ActionController::Base.send :include, Routes.url_helpers
  ActionController::Base.send :include, ActionController::Serialization
  Minitest::Test.send :include, DefineTestSerializerClass
end

ActionController::TestCase.class_eval do
  def setup
    @routes = TestHelper::Routes
  end
end

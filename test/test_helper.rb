require "bundler/setup"

require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require "active_support/json"
require 'minitest/autorun'

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

def def_serializer(&block)
  Class.new(ActiveModel::Serializer, &block)
end

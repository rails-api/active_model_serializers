require "rubygems"
require "bundler"

Bundler.setup

require "active_model_serializers"
require "active_support/json"
require "test/unit"

require 'rails'

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    match ':controller(/:action(/:id))'
    match ':controller(/:action)'
  end

  ActionController::Base.send :include, Routes.url_helpers
end

ActiveSupport::TestCase.class_eval do
  setup do
    @routes = ::TestHelper::Routes
  end
end

require "rubygems"
require "bundler/setup"

unless ENV["TRAVIS"]
  require 'simplecov'
  SimpleCov.start do
    add_group "lib", "lib"
    add_group "spec", "spec"
  end
end

require "pry"

require "active_model_serializers"
require "active_support/json"
require "test/unit"

require 'rails'

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    resource :hypermedia
    match ':controller(/:action(/:id))'
    match ':controller(/:action)'
  end

  ActionController::Base.send :include, Routes.url_helpers
  ActiveModel::Serializer.send :include, Routes.url_helpers
end

ActiveSupport::TestCase.class_eval do
  setup do
    @routes = ::TestHelper::Routes
  end
end

class Object
  undef_method :id if respond_to?(:id)
end
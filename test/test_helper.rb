require "rubygems"
require "bundler/setup"

require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
require 'active_support/json'

gem 'minitest'
require 'minitest/autorun'
if defined?(Minitest::Test)
  $minitest_version = 5 # rubocop:disable Style/GlobalVars
  # Minitest 5
  # https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest/autorun.rb
  # https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest.rb#L45-L59
else
  $minitest_version = 4 # rubocop:disable Style/GlobalVars
  # Minitest 4
  # https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/autorun.rb
  # https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/unit.rb#L768-L787
  # Ensure backward compatibility with Minitest 4
  Minitest = MiniTest unless defined?(Minitest)
  Minitest::Test = MiniTest::Unit::TestCase
  def Minitest.after_run(&block)
    MiniTest::Unit.after_tests(&block)
  end
end


require "pry"

require "active_model_serializers"

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    resource :hypermedia
    get ':controller(/:action(/:id))'
    get ':controller(/:action)'
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

require "support/rails5_shims"

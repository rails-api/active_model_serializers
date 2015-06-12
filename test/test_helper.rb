require 'bundler/setup'

require 'timecop'
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

# Use cleaner stream testing interface from Rails 5 if available
# see https://github.com/rails/rails/blob/29959eb59d/activesupport/lib/active_support/testing/stream.rb
begin
  require "active_support/testing/stream"
rescue LoadError
  module ActiveSupport
    module Testing
      module Stream #:nodoc:
        private

        def silence_stream(stream)
          old_stream = stream.dup
          stream.reopen(IO::NULL)
          stream.sync = true
          yield
        ensure
          stream.reopen(old_stream)
          old_stream.close
        end

        def quietly
          silence_stream(STDOUT) do
            silence_stream(STDERR) do
              yield
            end
          end
        end

        def capture(stream)
          stream = stream.to_s
          captured_stream = Tempfile.new(stream)
          stream_io = eval("$#{stream}")
          origin_stream = stream_io.dup
          stream_io.reopen(captured_stream)

          yield

          stream_io.rewind
          return captured_stream.read
        ensure
          captured_stream.close
          captured_stream.unlink
          stream_io.reopen(origin_stream)
        end
      end
    end
  end
end

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

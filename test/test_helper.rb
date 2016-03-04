# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require 'bundler/setup'

begin
  require 'simplecov'
  AppCoverage.start
rescue LoadError
  STDERR.puts 'Running without SimpleCov'
end

require 'timecop'
require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
require 'active_support/json'
require 'active_model_serializers'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../../tmp/cache', __FILE__))

gem 'minitest'
require 'minitest'
require 'minitest/autorun'
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require 'support/rails_app'

# require "rails/test_help"

require 'support/serialization_testing'

require 'support/rails5_shims'

require 'fixtures/active_record'

require 'fixtures/poro'

ActiveSupport.on_load(:action_controller) do
  $action_controller_logger = ActiveModelSerializers.logger
  ActiveModelSerializers.logger = Logger.new(IO::NULL)
end

require 'bundler/setup'

require 'timecop'
require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
require 'active_support/json'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../../tmp/cache', __FILE__))

require 'minitest/autorun'
# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)


require 'capture_warnings'
@capture_warnings = CaptureWarnings.new(fail_build = true)
@capture_warnings.before_tests
if Minitest.respond_to?(:after_run)
  Minitest.after_run do
    @capture_warnings.after_tests
  end
else
  at_exit do
    STDOUT.puts "Minitest.after_run not available."
    @capture_warnings.after_tests
  end
end

require 'active_model_serializers'

require 'support/stream_capture'

require 'support/rails_app'

require 'fixtures/poro'

require 'support/test_case'

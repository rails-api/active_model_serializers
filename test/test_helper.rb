require 'bundler/setup'

begin
  require 'simplecov'
  # HACK: till https://github.com/colszowka/simplecov/pull/400 is merged and released.
  # Otherwise you may get:
  # simplecov-0.10.0/lib/simplecov/defaults.rb:50: warning: global variable `$ERROR_INFO' not initialized
  require 'support/simplecov'
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
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../../tmp/cache', __FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
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

# If there's no failure info, try disabling capturing stderr:
# `env CAPTURE_STDERR=false rake`
# This is way easier than writing a Minitest plugin
# for 4.x and 5.x.
if ENV['CAPTURE_STDERR'] !~ /false|1/i
  require 'capture_warnings'
  CaptureWarnings.new(_fail_build = true).execute!
else
  $VERBOSE = true
end

require 'active_model_serializers'
require 'active_model/serializer/railtie'

require 'support/stream_capture'

require 'support/rails_app'

require 'support/test_case'

require 'support/serialization_testing'

require 'support/rails5_shims'

require 'fixtures/active_record'

require 'fixtures/poro'

ActiveSupport.on_load(:active_model_serializers) do
  $action_controller_logger = ActiveModelSerializers.logger # rubocop:disable Style/GlobalVars
  ActiveModelSerializers.logger = Logger.new(IO::NULL)
end

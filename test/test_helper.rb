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

# https://github.com/seattlerb/minitest/blob/master/lib/minitest/autorun.rb
gem 'minitest'
begin
  require 'minitest'
rescue LoadError
  # Minitest 4
  require 'minitest/unit'
  require 'minitest/spec'
  require 'minitest/mock'
  $minitest_version = 4
  # Minitest 4
  # https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/autorun.rb
  # https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/unit.rb#L768-L787
  # Ensure backward compatibility with Minitest 4
  Minitest = MiniTest unless defined?(Minitest)
  Minitest::Test = MiniTest::Unit::TestCase
  minitest_run = ->(argv) { MiniTest::Unit.new.run(argv) }
else
  # Minitest 5
  $minitest_version = 5
  # Minitest 5
  # https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest/autorun.rb
  # https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest.rb#L45-L59
  require 'minitest/spec'
  require 'minitest/mock'
  minitest_run = ->(argv) { Minitest.run(argv) }
end
require 'minitest/reporters'
Minitest::Reporters.use!

# If there's no failure info, try disabling capturing stderr:
# `env CAPTURE_STDERR=false rake`
# This is way easier than writing a Minitest plugin
# for 4.x and 5.x.
if ENV['CAPTURE_STDERR'] !~ /false|1/i
  require 'capture_warnings'
  minitest_run = CaptureWarnings.new(_fail_build = true).execute!(minitest_run)
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
  $action_controller_logger = ActiveModelSerializers.logger
  ActiveModelSerializers.logger = Logger.new(IO::NULL)
end

# From:
# https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/unit.rb#L768-L787
# https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest.rb#L45-L59
# But we've replaced `at_exit` with `END` called before the 'at_exit' hook.
class MiniTestHack
  def self.autorun(minitest_run)
    # don't run if there was a non-exit exception
    return if $! and not ($!.kind_of? SystemExit and $!.success?)

    # Original Comment:
    # the order here is important. The at_exit handler must be
    # installed before anyone else gets a chance to install their
    # own, that way we can be assured that our exit will be last
    # to run (at_exit stacks).
    #
    # Now:
    # The after_run blocks now only run on SigEXIT, which is fine.
    exit_code = nil

    trap('EXIT') do
      if $minitest_version == 5
        @@after_run.reverse_each(&:call)
      else
        @@after_tests.reverse_each(&:call)
      end

      exit exit_code || false
    end

    exit_code = minitest_run.call(ARGV)
  end
end
# Run MiniTest in `END`, so that it finishes before `at_exit` fires,
# which guarantees we can run code after MiniTest finishes
# via an `at_exit` block.
# This is in service of silencing non-app warnings during test run,
# and leaves us with the warnings in our app.
END { MiniTestHack.autorun(minitest_run) }

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
begin
  require 'minitest'
rescue LoadError
  # Minitest 4
  require 'minitest/autorun'
  $minitest_version = 4
  # https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/autorun.rb
  # https://github.com/seattlerb/minitest/blob/644a52fd0/lib/minitest/unit.rb#L768-L787
  # Ensure backward compatibility with Minitest 4
  Minitest = MiniTest unless defined?(Minitest)
  Minitest::Test = MiniTest::Unit::TestCase
else
  # Minitest 5
  require 'minitest/autorun'
  $minitest_version = 5
  # https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest/autorun.rb
  # https://github.com/seattlerb/minitest/blob/e21fdda9d/lib/minitest.rb#L45-L59
end

require 'support/rails_app'

require 'support/test_case'

require 'support/serialization_testing'

require 'support/collection_serializer_testing'

require 'support/rails5_shims'

require 'fixtures/active_record'

require 'fixtures/poro'

ActiveSupport.on_load(:action_controller) do
  $action_controller_logger = ActiveModelSerializers.logger
  ActiveModelSerializers.logger = Logger.new(IO::NULL)
end

require 'test_helper'

class ActiveModelSerializers::LoggerTest < Minitest::Test

  def test_logger_is_set_to_action_controller_logger_when_initializer_runs
    assert_equal ActiveModelSerializers.logger, ActionController::Base.logger
  end

  def test_logger_can_be_set
    original_logger = ActiveModelSerializers.logger
    logger = Logger.new(STDOUT)

    ActiveModelSerializers.logger = logger

    assert_equal ActiveModelSerializers.logger, logger
  ensure
    ActiveModelSerializers.logger = original_logger
  end
end

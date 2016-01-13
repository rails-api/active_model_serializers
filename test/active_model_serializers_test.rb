require 'test_helper'

class ActiveModelSerializers::Test < ActiveSupport::TestCase
  test 'truth' do
    assert_kind_of Module, ActiveModelSerializers
  end
end

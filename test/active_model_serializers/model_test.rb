require 'test_helper'

class ActiveModelSerializers::ModelTest < Minitest::Test
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = ActiveModelSerializers::Model.new
  end
end

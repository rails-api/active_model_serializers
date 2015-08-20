require 'test_helper'

class PoroTest < Minitest::Test
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = Model.new
  end
end

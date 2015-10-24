require 'test_helper'

class ActiveModel::Serializer::ModelTest < Minitest::Test
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = ActiveModel::Serializer::Model.new
  end
end

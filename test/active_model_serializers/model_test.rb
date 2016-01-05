require 'test_helper'

class ActiveModelSerializers::ModelTest < ActiveSupport::TestCase
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = ActiveModelSerializers::Model.new
  end
end

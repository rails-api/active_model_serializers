require 'test_helper'

module ActiveModelSerializers
  class ModelTest < ActiveSupport::TestCase
    include ActiveModel::Serializer::Lint::Tests

    def setup
      @resource = ActiveModelSerializers::Model.new
    end
  end
end

module ActiveModelSerializers
  module RSpec
    # @api public
    # Container module for active_model_serializers specific matchers.
    module Matchers
    end
  end
end

require_relative 'matchers/serializer'
require_relative 'matchers/schema'

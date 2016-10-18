module ActiveModelSerializers
  # @api public
  # Container module for active_model_serializers specific matchers.
  module RSpecMatchers
    # extend ActiveSupport::Autoload
    # autoload :Serializer
    # autoload :Schema
  end
end

require_relative 'matchers/serializer'
require_relative 'matchers/schema'

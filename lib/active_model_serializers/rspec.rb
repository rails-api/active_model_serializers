module ActiveModelSerializers
  # @api public
  # Container module for active_model_serializers specific matchers.
  module RSpecMatchers
    extend ActiveSupport::Autoload
    autoload :Schema, 'active_model_serializers/rspec_matchers/schema'
  end
end

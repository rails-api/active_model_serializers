# frozen_string_literal: true

module AMS
  module DSLSupport
    # @api private
    # Macro to add an instance method to the receiver
    def add_instance_method(body, receiver)
      cl = caller_locations[0]
      silence_warnings { receiver.module_eval body, cl.absolute_path, cl.lineno }
    end

    # @api private
    # Macro to add a class method to the receiver
    def add_class_method(body, receiver)
      cl = caller_locations[0]
      silence_warnings { receiver.class_eval body, cl.absolute_path, cl.lineno }
    end

    # @api private
    # Silence warnings, primarily when redefining methods
    def silence_warnings
      original_verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = original_verbose
    end
  end
end

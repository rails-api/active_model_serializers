# frozen_string_literal: true

# HACK: to prevent the resetting of instance variables after each request in Rails 7
# see https://github.com/rails/rails/pull/43735
if Rails::VERSION::MAJOR >= 7
  module ActionController
    module Testing
      module Functional
        def clear_instance_variables_between_requests; end
      end
    end
  end
end

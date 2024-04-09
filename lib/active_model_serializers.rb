# frozen_string_literal: true

require 'active_model'
require 'active_model/serializer'
require 'active_model/serializer_support'
require 'active_model/serializer/version'
require 'active_model/serializer/railtie' if defined?(Rails)

begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    if ::ActionController::Serialization.enabled
      ActionController::Base.send(:include, ::ActionController::Serialization)

      # action_controller_test_case load hook was added in Rails 5.1
      # https://github.com/rails/rails/commit/0510208dd1ff23baa619884c0abcae4d141fae53
      if ActiveSupport::VERSION::STRING < '5.1'
        require 'action_controller/serialization_test_case'
        ActionController::TestCase.send(:include, ::ActionController::SerializationAssertions)
      else
        ActiveSupport.on_load(:action_controller_test_case) do
          require 'action_controller/serialization_test_case'
          ActionController::TestCase.send(:include, ::ActionController::SerializationAssertions)
        end
      end
    end
  end
rescue LoadError
  # rails not installed, continuing
end

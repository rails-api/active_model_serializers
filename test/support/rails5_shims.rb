module Rails5Shims
  module ControllerTests
    # https://github.com/rails/rails/blob/b217354/actionpack/lib/action_controller/test_case.rb
    REQUEST_KWARGS = [:params, :session, :flash, :method, :body, :xhr]

    # Fold kwargs from test request into args
    # Band-aid for DEPRECATION WARNING
    def get(path, *args)
      hash = args && args[0]
      if hash.respond_to?(:key)
        Rails5Shims::ControllerTests::REQUEST_KWARGS.each do |kwarg|
          next unless hash.key?(kwarg)
          hash.merge! hash.delete(kwarg)
        end
      end
      super
    end

    # Uncomment for debugging where the kwargs warnings come from
    # def non_kwarg_request_warning
    #   super.tap do
    #     STDOUT.puts caller[2..3]
    #   end
    # end
  end
end
if Rails::VERSION::MAJOR < 5
  ActionController::TestCase.send :include, Rails5Shims::ControllerTests
end

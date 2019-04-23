# frozen_string_literal: true

if RUBY_VERSION >= '2.6.0'
  if Rails::VERSION::MAJOR < 5
    module ActionController
      class TestResponse < ActionDispatch::TestResponse
        def recycle!
          # HACK: to avoid MonitorMixin double-initialize error:
          @mon_mutex_owner_object_id = nil
          @mon_mutex = nil
          initialize
        end
      end
    end
  else
    msg = 'Monkeypatch for ActionController::TestResponse not needed for '\
      'Rails 5+. We can drop this patch once we drop support for Rails < 5. '\
      "Current Rails version: #{ENV['RAILS_VERSION']}"

    puts
    puts "\033[33m **** #{msg} **** \033[0m"
    puts
  end
end

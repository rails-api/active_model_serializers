class Foo < Rails::Application
  if Rails::VERSION::MAJOR >= 4
    config.eager_load = false
    config.secret_key_base = 'abc123'
    config.action_controller.perform_caching = true
    config.active_support.test_order = :random
    config.logger = Logger.new(nil)
    ActionController::Base.cache_store = :memory_store
  end
end
Foo.initialize!

module TestHelper
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    get ':controller(/:action(/:id))'
    get ':controller(/:action)'
  end

  ActionController::Base.send :include, Routes.url_helpers
end

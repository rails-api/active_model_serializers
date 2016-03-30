require 'support/isolated_unit'
module ActiveModelSerializers
  RailsApplication = TestHelpers::Generation.make_basic_app do |app|
    app.configure do
      config.secret_key_base = 'abc123'
      config.active_support.test_order = :random
      config.action_controller.perform_caching = true
      # TODO: figure out why turning on the memory cache changes
      # the result of the CacheTest#test_associations_cache_when_updated
      # and if it is more correct or less correct.
      config.action_controller.cache_store = :memory_store
    end

    app.routes.default_url_options = { host: 'example.com' }
  end
end

Routes = ActionDispatch::Routing::RouteSet.new
Routes.draw do
  get ':controller(/:action(/:id))'
  get ':controller(/:action)'
end
ActionController::Base.send :include, Routes.url_helpers
ActionController::TestCase.class_eval do
  def setup
    @routes = Routes
  end

  # For Rails5
  # https://github.com/rails/rails/commit/ca83436d1b3b6cedd1eca2259f65661e69b01909#diff-b9bbf56e85d3fe1999f16317f2751e76L17
  def assigns(key = nil)
    warn "DEPRECATION: Calling 'assigns(#{key})' from #{caller[0]}"
    assigns = {}.with_indifferent_access
    @controller.view_assigns.each { |k, v| assigns.regular_writer(k, v) }
    key.nil? ? assigns : assigns[key]
  end
end

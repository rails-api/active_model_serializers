require 'support/isolated_unit'
module ActiveModelSerializers
  RailsApplication = TestHelpers::Generation.make_basic_app do |app|
    app.configure do
      config.secret_key_base = 'abc123'
      config.active_support.test_order = :random
      config.action_controller.perform_caching = true
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

# ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
# ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)
#
# Load fixtures from the engine
# if ActiveSupport::TestCase.respond_to?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
#   ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
#   ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
#   ActiveSupport::TestCase.fixtures :all
# end

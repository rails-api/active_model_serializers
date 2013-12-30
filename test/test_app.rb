class TestApp < Rails::Application
  if Rails.version.to_s.first >= '4'
    config.eager_load = false
    config.secret_key_base = 'abc123'
  end
end

TestApp.initialize!

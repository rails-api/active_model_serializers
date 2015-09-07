class Minitest::Test
  def before_setup
    ActionController::Base.cache_store.clear
  end

  def with_adapter(adapter)
    old_adapter = ActiveModel::Serializer.config.adapter
    ActiveModel::Serializer.config.adapter = adapter
    yield
  ensure
    ActiveModel::Serializer.config.adapter = old_adapter
  end
end

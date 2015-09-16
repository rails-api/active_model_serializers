module SerializationTesting
  private

  def generate_cached_serializer(obj)
    ActiveModel::SerializableResource.new(obj).to_json
  end

  # Aliased as :with_configured_adapter to clarify that
  # this method tests the configured adapter.
  # When not testing configuration, it may be preferable
  # to pass in the +adapter+ option to <tt>ActiveModel::SerializableResource</tt>.
  # e.g ActiveModel::SerializableResource.new(resource, adapter: :json_api)
  def with_adapter(adapter)
    old_adapter = ActiveModel::Serializer.config.adapter
    ActiveModel::Serializer.config.adapter = adapter
    yield
  ensure
    ActiveModel::Serializer.config.adapter = old_adapter
  end
  alias_method :with_configured_adapter, :with_adapter
end

class Minitest::Test
  def before_setup
    ActionController::Base.cache_store.clear
  end

  include SerializationTesting
end

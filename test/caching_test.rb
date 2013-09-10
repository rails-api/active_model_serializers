require "test_helper"

class CachingTest < ActiveModel::TestCase
  class NullStore
    def fetch(key)
      return store[key] if store[key]

      store[key] = yield
    end

    def clear
      store.clear
    end

    def store
      @store ||= {}
    end

    def read(key)
      store[key]
    end
  end

  class Programmer
    def name
      'Adam'
    end

    def skills
      %w(ruby)
    end

    def read_attribute_for_serialization(name)
      send name
    end
  end

  def setup
    ActiveModel::Serializer::Caching.cache_store = NullStore.new
  end


  def test_serializers_have_a_cache_store
    assert_kind_of NullStore, ActiveModel::Serializer::Caching.cache_store
  end

  def test_serializers_can_enable_caching
    serializer = Class.new(ActiveModel::Serializer) do
      cached true
    end

    assert serializer.cache_enabled
  end

  def test_serializers_use_cache
    ActiveModel::Serializer::Caching.perform_caching = true

    serializer = Class.new(ActiveModel::Serializer) do
      cached true
      attributes :name, :skills

      def self.to_s
        'serializer'
      end

      def cache_key
        object.name
      end
    end

    instance = serializer.new Programmer.new

    instance.to_json

    assert_equal(instance.serializable_hash, ActiveModel::Serializer::Caching.cache_store.read('serializer/Adam/serialize'))
    assert_equal(instance.to_json, ActiveModel::Serializer::Caching.cache_store.read('serializer/Adam/to-json'))
  end

  def test_array_serializer_uses_cache
    ActiveModel::Serializer::Caching.perform_caching = true

    serializer = Class.new(ActiveModel::ArraySerializer) do
      cached true

      def self.to_s
        'array_serializer'
      end

      def cache_key
        'cache-key'
      end
    end

    instance = serializer.new [Programmer.new]

    instance.to_json

    assert_equal instance.serializable_array, ActiveModel::Serializer::Caching.cache_store.read('array_serializer/cache-key/serialize')
    assert_equal instance.to_json, ActiveModel::Serializer::Caching.cache_store.read('array_serializer/cache-key/to-json')
  end

  def test_turning_off_all_caching_via_config_disables_serializer_caching
    ActiveModel::Serializer::Caching.perform_caching = false

    serializer = Class.new(ActiveModel::Serializer) do
      cached true
      attributes :name, :skills

      def self.to_s
        'serializer'
      end

      def cache_key
        object.name
      end
    end

    instance = serializer.new Programmer.new

    instance.to_json

    assert_nil ActiveModel::Serializer::Caching.cache_store.read('serializer/Adam/serialize')
    assert_nil ActiveModel::Serializer::Caching.cache_store.read('serializer/Adam/to-json')
  end

  def test_turning_off_all_caching_via_config_disables_array_serializer_caching
    ActiveModel::Serializer::Caching.perform_caching = false

    serializer = Class.new(ActiveModel::ArraySerializer) do
      cached true

      def self.to_s
        'array_serializer'
      end

      def cache_key
        'cache-key'
      end
    end

    instance = serializer.new [Programmer.new]

    instance.to_json

    assert_nil ActiveModel::Serializer::Caching.cache_store.read('array_serializer/cache-key/serialize')
    assert_nil ActiveModel::Serializer::Caching.cache_store.read('array_serializer/cache-key/to-json')
  end
end

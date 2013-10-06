require "test_helper"

class CachingTest < ActiveModel::TestCase
  class NullStore
    def fetch(key, options = {})
      return store[key] if store[key]

      stored_options[key] = options
      store[key]   = yield
    end

    def clear
      store.clear
      options.clear
    end

    def store
      @store ||= {}
    end

    def read(key)
      store[key]
    end

    def stored_options
      @stored_options ||= {}
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

  def test_serializers_have_a_cache_store
    ActiveModel::Serializer.cache = NullStore.new

    assert_kind_of NullStore, ActiveModel::Serializer.cache
  end

  def test_serializers_can_enable_caching
    serializer = Class.new(ActiveModel::Serializer) do
      cached true
    end

    assert serializer.perform_caching
  end

  def test_serializers_use_cache
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

    serializer.cache = NullStore.new
    instance = serializer.new Programmer.new

    instance.to_json

    assert_equal(instance.serializable_hash, serializer.cache.read('serializer/Adam/serialize'))
    assert_equal(instance.to_json, serializer.cache.read('serializer/Adam/to-json'))
  end

  def test_array_serializer_uses_cache
    serializer = Class.new(ActiveModel::ArraySerializer) do
      cached true

      def self.to_s
        'array_serializer'
      end

      def cache_key
        'cache-key'
      end
    end

    serializer.cache = NullStore.new
    instance = serializer.new [Programmer.new]

    instance.to_json

    assert_equal instance.serializable_array, serializer.cache.read('array_serializer/cache-key/serialize')
    assert_equal instance.to_json, serializer.cache.read('array_serializer/cache-key/to-json')
  end

  def test_serializers_uses_cache_with_options
    serializer = Class.new(ActiveModel::Serializer) do
      cached true
      attributes :name, :skills

      def self.to_s
        'serializer'
      end

      def cache_key
        object.name
      end

      def cache_options
        { race_condition_ttl: 10, expires_in: 1.minute }
      end
    end

    cache = NullStore.new
    serializer.cache = cache
    instance = serializer.new Programmer.new

    instance.to_json

    assert_equal cache.stored_options.size, 2
    cache.stored_options { |key, options| assert_equal options, { race_condition_ttl: 10, expires_in: 1.minute } }
  end

  def test_array_serializer_uses_cache_with_options
    serializer = Class.new(ActiveModel::ArraySerializer) do
      cached true

      def self.to_s
        'array_serializer'
      end

      def cache_key
        'cache-key'
      end

      def cache_options
        { race_condition_ttl: 10, expires_in: 1.minute }
      end

    end

    cache = NullStore.new
    serializer.cache = cache
    instance = serializer.new [Programmer.new]

    instance.to_json

    assert_equal cache.stored_options.size, 2
    cache.stored_options { |key, options| assert_equal options, { race_condition_ttl: 10, expires_in: 1.minute } }
  end

end

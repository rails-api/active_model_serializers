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

    def cache_key
      name
    end

    def read_attribute_for_serialization(name)
      send name
    end
  end

  def test_serializers_have_a_cache_store
    ActiveModel::Serializer.cache = NullStore.new

    assert ActiveModel::Serializer.cache
  end

  def test_serializers_can_enable_caching
    serializer = Class.new(ActiveModel::Serializer) do
      cache true
    end

    assert serializer.perform_caching
  end

  def test_serializers_cache_serializable_hash
    serializer = Class.new(ActiveModel::Serializer) do
      cache true
      attributes :name, :skills

      def self.to_s
        'serializer'
      end
    end

    serializer.cache = NullStore.new
    instance = serializer.new Programmer.new

    instance.to_json

    assert_equal({
      :name => 'Adam',
      :skills => ['ruby'],
    }, serializer.cache.read('serializer/Adam/serializable-hash'))
  end

  def test_serializers_cache_to_json
    serializer = Class.new(ActiveModel::Serializer) do
      cache true
      attributes :name, :skills

      def self.to_s
        'serializer'
      end
    end

    serializer.cache = NullStore.new
    instance = serializer.new Programmer.new

    instance.to_json

    assert_equal({
      :name => 'Adam',
      :skills => ['ruby'],
    }.to_json, serializer.cache.read('serializer/Adam/to-json'))
  end
end

require "test_helper"

class CachingTest < ActiveModel::TestCase
  class NullStore
    def fetch(key)
      return store[key] if store[key]

      store[key] = yield
    end

    def read_multi(*keys)
      results = {}

      keys.each do |key|
        if entity = store[key]
          hash[key] = entity
        end
      end

      results
    end

    def fetch_multi(*keys)
      results = read_multi(*keys)

      keys.flatten.map do |key|
        results.fetch(key) do
          value = yield key
          store[key] = value
          value
        end
      end
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
    attr_reader :name, :skills

    def initialize(name = 'Adam', skills = %w[ruby])
      @name   = name
      @skills = skills
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

  def test_array_serializer_caches_all_contained_objects
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

    array_serializer = Class.new(ActiveModel::ArraySerializer) do
      cached true
    end

    serializer.cache = array_serializer.cache = NullStore.new

    model_instance_a = serializer.new(Programmer.new('Yehuda'))
    model_instance_b = serializer.new(Programmer.new('Jose'))
    array_instance   = array_serializer.new [model_instance_a, model_instance_b]

    array_instance.to_json.tap do |json|
      assert_match('Yehuda', json)
      assert_match('Jose',   json)
    end

    assert_equal(model_instance_a.to_json,           serializer.cache.read('serializer/Yehuda/to-json'))
    assert_equal(model_instance_a.serializable_hash, serializer.cache.read('serializer/Yehuda/serialize'))
    assert_equal(model_instance_b.to_json,           serializer.cache.read('serializer/Jose/to-json'))
    assert_equal(model_instance_b.serializable_hash, serializer.cache.read('serializer/Jose/serialize'))
  end
end

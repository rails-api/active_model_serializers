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
    def active_model_serializer
      ProgrammerSerializer
    end

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

  class Library
    attr_accessor :id, :name
    alias :read_attribute_for_serialization :send
    def active_model_serializer
      LibrarySerializer
    end
  end

  ##
  # Serializers
  class ProgrammerSerializer < ActiveModel::Serializer
    cached true
    attributes :name, :skills
    has_many :libraries, embed: :ids, include: true

    def self.to_s
      'programmer_serializer'
    end

    def cache_key
      object.name
    end

    def libraries
      l = Library.new
      l.id = 1
      l.name = 'AMS'

      l2 = Library.new
      l2.id = 2
      l2.name = 'RoR'

      [l, l2]
    end
  end

  class LibrarySerializer < ActiveModel::Serializer
    cached true
    attributes :id, :name

    def self.to_s
      'library_serializer'
    end

    def cache_key
      object.name
    end
  end 

  ##
  # ArraySerializers
  class ProgrammersSerializer < ActiveModel::ArraySerializer
    cached true

    def self.to_s
      'array_serializer'
    end

    def cache_key
      'cache-key'
    end
  end

  def test_serializer_to_json_cache_after_array_serializer_cache_includes_associations
    ProgrammersSerializer.cache = NullStore.new
    ProgrammerSerializer.cache = ProgrammersSerializer.cache
    LibrarySerializer.cache = ProgrammersSerializer.cache

    programmer = Programmer.new
    instance = ProgrammersSerializer.new [programmer], { root: "programmers" }

    instance.to_json

    assert JSON.parse(ProgrammersSerializer.cache.read('array_serializer/cache-key/to-json')).has_key?("libraries"), "JSON should include sideloaded Libraries"
    assert_equal instance.to_json, ProgrammersSerializer.cache.read('array_serializer/cache-key/to-json')
    assert_equal instance.serializable_array, ProgrammersSerializer.cache.read('array_serializer/cache-key/serializable-array')

    # ArraySerializer _does not_ generate the to-json cache, only the 
    # serialized-hash cache, so let's generate the to-json cache here where the
    # serialized-hash cache already exists.
    programmer_instance = ProgrammerSerializer.new programmer
    programmer_instance.to_json

    # The to-json cache here _will not_ include the associations in the cache 
    # because when serializable_hash is cached, include_associations! isn't 
    # called which populated @options[:hash] with the associations to sideload.
    # Let's save what's cached here to compare with when an ArraySerializer 
    # isn't the first to serialize a record.
    programmer_cache_via_array = ProgrammersSerializer.cache.read("programmer_serializer/#{programmer.name}/to-json")

    # Clear cache so we can load the record again directly, not via an
    # ArraySerializer
    # puts ProgrammersSerializer.cache.store
    ProgrammersSerializer.cache.clear

    programmer_instance = ProgrammerSerializer.new programmer
    programmer_instance.to_json
    # puts ProgrammersSerializer.cache.store

    programmer_cache_via_direct = ProgrammersSerializer.cache.read("programmer_serializer/#{programmer.name}/to-json")

    # These should be equal, but the programmer_cache_via_array is missing the 
    # sideload associations.
    assert_equal programmer_cache_via_direct, programmer_cache_via_array 
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

    assert_equal(instance.serializable_hash, serializer.cache.read('serializer/Adam/serializable-hash'))
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

    assert_equal instance.serializable_array, serializer.cache.read('array_serializer/cache-key/serializable-array')
    assert_equal instance.to_json, serializer.cache.read('array_serializer/cache-key/to-json')
  end

end

require 'test_helper'

module ActiveModelSerializers
  class AdapterTest < ActiveSupport::TestCase
    def setup
      profile = Profile.new
      @serializer = ProfileSerializer.new(profile)
      @adapter = ActiveModelSerializers::Adapter::Base.new(@serializer)
    end

    def test_serializable_hash_is_abstract_method
      assert_raises(NotImplementedError) do
        @adapter.serializable_hash(only: [:name])
      end
    end

    def test_serializer
      assert_equal @serializer, @adapter.serializer
    end

    def test_create_adapter
      adapter = ActiveModelSerializers::Adapter.create(@serializer)
      assert_equal ActiveModelSerializers::Adapter::Attributes, adapter.class
    end

    def test_create_adapter_with_override
      adapter = ActiveModelSerializers::Adapter.create(@serializer, { adapter: :json_api })
      assert_equal ActiveModelSerializers::Adapter::JsonApi, adapter.class
    end

    def test_inflected_adapter_class_for_known_adapter
      ActiveSupport::Inflector.inflections(:en) { |inflect| inflect.acronym 'API' }
      klass = ActiveModelSerializers::Adapter.adapter_class(:json_api)

      ActiveSupport::Inflector.inflections.acronyms.clear

      assert_equal ActiveModelSerializers::Adapter::JsonApi, klass
    end
  end
end

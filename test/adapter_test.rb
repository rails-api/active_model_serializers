require 'test_helper'

module ActiveModelSerializers
  class AdapterTest < ActiveSupport::TestCase
    def setup
      profile = Profile.new
      @serializer = ProfileSerializer.new(profile)
      @adapter = ActiveModelSerializers::Adapter::Base.new(@serializer)
    end

    test 'serializable_hash_is_abstract_method' do
      assert_raises(NotImplementedError) do
        @adapter.serializable_hash(only: [:name])
      end
    end

    test 'serialization_options_ensures_option_is_a_hash' do
      adapter = Class.new(ActiveModelSerializers::Adapter::Base) do
        def serializable_hash(options = nil)
          serialization_options(options)
        end
      end.new(@serializer)
      assert_equal({}, adapter.serializable_hash(nil))
      assert_equal({}, adapter.serializable_hash({}))
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete_if { |k, _| k =~ /class/ }
    end

    test 'serialization_options_ensures_option_is_one_of_valid_options' do
      adapter = Class.new(ActiveModelSerializers::Adapter::Base) do
        def serializable_hash(options = nil)
          serialization_options(options)
        end
      end.new(@serializer)
      filtered_options = { now: :see_me, then: :not }
      valid_options = ActiveModel::Serializer::SERIALIZABLE_HASH_VALID_KEYS.each_with_object({}) do |option, result|
        result[option] = option
      end
      assert_equal(valid_options, adapter.serializable_hash(filtered_options.merge(valid_options)))
    ensure
      ActiveModelSerializers::Adapter.adapter_map.delete_if { |k, _| k =~ /class/ }
    end

    test 'serializer' do
      assert_equal @serializer, @adapter.serializer
    end

    test 'create_adapter' do
      adapter = ActiveModelSerializers::Adapter.create(@serializer)
      assert_equal ActiveModelSerializers::Adapter::Attributes, adapter.class
    end

    test 'create_adapter_with_override' do
      adapter = ActiveModelSerializers::Adapter.create(@serializer, adapter: :json_api)
      assert_equal ActiveModelSerializers::Adapter::JsonApi, adapter.class
    end

    test 'inflected_adapter_class_for_known_adapter' do
      ActiveSupport::Inflector.inflections(:en) { |inflect| inflect.acronym 'API' }
      klass = ActiveModelSerializers::Adapter.adapter_class(:json_api)

      ActiveSupport::Inflector.inflections.acronyms.clear

      assert_equal ActiveModelSerializers::Adapter::JsonApi, klass
    end
  end
end

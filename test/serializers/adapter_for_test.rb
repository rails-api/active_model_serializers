module ActiveModel
  class Serializer
    class AdapterForTest < Minitest::Test
      UnknownAdapterError = ::ActiveModel::Serializer::Adapter::UnknownAdapterError

      def setup
        @previous_adapter = ActiveModel::Serializer.config.adapter
      end

      def teardown
        ActiveModel::Serializer.config.adapter = @previous_adapter
      end

      def test_returns_default_adapter
        adapter = ActiveModel::Serializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::Attributes, adapter
      end

      def test_overwrite_adapter_with_symbol
        ActiveModel::Serializer.config.adapter = :null

        adapter = ActiveModel::Serializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::Null, adapter
      ensure
        ActiveModel::Serializer.config.adapter = @previous_adapter
      end

      def test_overwrite_adapter_with_class
        ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::Null

        adapter = ActiveModel::Serializer.adapter
        assert_equal ActiveModel::Serializer::Adapter::Null, adapter
      end

      def test_raises_exception_if_invalid_symbol_given
        ActiveModel::Serializer.config.adapter = :unknown

        assert_raises UnknownAdapterError do
          ActiveModel::Serializer.adapter
        end
      end

      def test_raises_exception_if_it_does_not_know_hot_to_infer_adapter
        ActiveModel::Serializer.config.adapter = 42

        assert_raises UnknownAdapterError do
          ActiveModel::Serializer.adapter
        end
      end

      def test_adapter_class_for_known_adapter
        klass = ActiveModel::Serializer::Adapter.adapter_class(:json_api)
        assert_equal ActiveModel::Serializer::Adapter::JsonApi, klass
      end

      def test_adapter_class_for_unknown_adapter
        assert_raises UnknownAdapterError do
          ActiveModel::Serializer::Adapter.adapter_class(:json_simple)
        end
      end

      def test_adapter_map
        expected_adapter_map = {
          'null'.freeze       => ActiveModel::Serializer::Adapter::Null,
          'json'.freeze       => ActiveModel::Serializer::Adapter::Json,
          'attributes'.freeze => ActiveModel::Serializer::Adapter::Attributes,
          'json_api'.freeze   => ActiveModel::Serializer::Adapter::JsonApi
        }
        actual               = ActiveModel::Serializer::Adapter.adapter_map
        assert_equal actual, expected_adapter_map
      end

      def test_adapters
        assert_equal ActiveModel::Serializer::Adapter.adapters.sort, [
          'attributes'.freeze,
          'json'.freeze,
          'json_api'.freeze,
          'null'.freeze
        ]
      end

      def test_lookup_adapter_by_string_name
        assert_equal ActiveModel::Serializer::Adapter.lookup('json'.freeze), ActiveModel::Serializer::Adapter::Json
      end

      def test_lookup_adapter_by_symbol_name
        assert_equal ActiveModel::Serializer::Adapter.lookup(:json), ActiveModel::Serializer::Adapter::Json
      end

      def test_lookup_adapter_by_class
        klass = ActiveModel::Serializer::Adapter::Json
        assert_equal ActiveModel::Serializer::Adapter.lookup(klass), klass
      end

      def test_lookup_adapter_from_environment_registers_adapter
        ActiveModel::Serializer::Adapter.const_set(:AdapterFromEnvironment, Class.new)
        klass = ::ActiveModel::Serializer::Adapter::AdapterFromEnvironment
        name = 'adapter_from_environment'.freeze
        assert_equal ActiveModel::Serializer::Adapter.lookup(name), klass
        assert ActiveModel::Serializer::Adapter.adapters.include?(klass.name.underscore)
      ensure
        ActiveModel::Serializer::Adapter.adapter_map.delete(klass.name.underscore)
        ActiveModel::Serializer::Adapter.send(:remove_const, :AdapterFromEnvironment)
      end

      def test_lookup_adapter_for_unknown_name
        assert_raises UnknownAdapterError do
          ActiveModel::Serializer::Adapter.lookup(:json_simple)
        end
      end

      def test_adapter
        assert_equal ActiveModel::Serializer.config.adapter, :attributes
        assert_equal ActiveModel::Serializer.adapter, ActiveModel::Serializer::Adapter::Attributes
      end

      def test_register_adapter
        new_adapter_klass = Class
        ActiveModel::Serializer::Adapter.register(new_adapter_klass)
        assert ActiveModel::Serializer::Adapter.adapters.include?(new_adapter_klass.name.underscore)
        assert ActiveModel::Serializer::Adapter.lookup(new_adapter_klass.name), new_adapter_klass
      ensure
        ActiveModel::Serializer::Adapter.adapter_map.delete(new_adapter_klass.name.underscore)
      end

      def test_inherited_adapter_hooks_register_adapter
        Object.const_set(:MyAdapter, Class.new)
        my_adapter = MyAdapter
        ActiveModel::Serializer::Adapter::Base.inherited(my_adapter)
        assert_equal ActiveModel::Serializer::Adapter.lookup(:my_adapter), my_adapter
      ensure
        ActiveModel::Serializer::Adapter.adapter_map.delete('my_adapter'.freeze)
        Object.send(:remove_const, :MyAdapter)
      end

      def test_inherited_adapter_hooks_register_namespaced_adapter
        Object.const_set(:MyNamespace, Module.new)
        MyNamespace.const_set(:MyAdapter, Class.new)
        my_adapter = MyNamespace::MyAdapter
        ActiveModel::Serializer::Adapter::Base.inherited(my_adapter)
        assert_equal ActiveModel::Serializer::Adapter.lookup(:'my_namespace/my_adapter'), my_adapter
      ensure
        ActiveModel::Serializer::Adapter.adapter_map.delete('my_namespace/my_adapter'.freeze)
        MyNamespace.send(:remove_const, :MyAdapter)
        Object.send(:remove_const, :MyNamespace)
      end

      def test_inherited_adapter_hooks_register_subclass_of_registered_adapter
        Object.const_set(:MyAdapter, Class.new)
        my_adapter = MyAdapter
        Object.const_set(:MySubclassedAdapter, Class.new(MyAdapter))
        my_subclassed_adapter = MySubclassedAdapter
        ActiveModel::Serializer::Adapter::Base.inherited(my_adapter)
        ActiveModel::Serializer::Adapter::Base.inherited(my_subclassed_adapter)
        assert_equal ActiveModel::Serializer::Adapter.lookup(:my_adapter), my_adapter
        assert_equal ActiveModel::Serializer::Adapter.lookup(:my_subclassed_adapter), my_subclassed_adapter
      ensure
        ActiveModel::Serializer::Adapter.adapter_map.delete('my_adapter'.freeze)
        ActiveModel::Serializer::Adapter.adapter_map.delete('my_subclassed_adapter'.freeze)
        Object.send(:remove_const, :MyAdapter)
        Object.send(:remove_const, :MySubclassedAdapter)
      end
    end
  end
end

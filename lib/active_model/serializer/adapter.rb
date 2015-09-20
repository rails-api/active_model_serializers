module ActiveModel
  class Serializer
    module Adapter
      UnknownAdapterError = Class.new(ArgumentError)
      ADAPTER_MAP = {}
      private_constant :ADAPTER_MAP if defined?(private_constant)
      require 'active_model/serializer/adapter/fragment_cache'
      require 'active_model/serializer/adapter/cached_serializer'

      class << self # All methods are class functions
        def new(*args)
          fail ArgumentError, 'Adapters inherit from Adapter::Base.' \
            "Adapter.new called with args: '#{args.inspect}', from" \
            "'caller[0]'."
        end

        def create(resource, options = {})
          override = options.delete(:adapter)
          klass = override ? adapter_class(override) : ActiveModel::Serializer.adapter
          klass.new(resource, options)
        end

        # @see ActiveModel::Serializer::Adapter.lookup
        def adapter_class(adapter)
          ActiveModel::Serializer::Adapter.lookup(adapter)
        end

        # @return Hash<adapter_name, adapter_class>
        def adapter_map
          ADAPTER_MAP
        end

        # @return [Array<Symbol>] list of adapter names
        def adapters
          adapter_map.keys.sort
        end

        # Adds an adapter 'klass' with 'name' to the 'adapter_map'
        # Names are stringified and underscored
        # @param name [Symbol, String, Class] name of the registered adapter
        # @param klass [Class] adapter class itself, optional if name is the class
        # @example
        #     AMS::Adapter.register(:my_adapter, MyAdapter)
        # @note The registered name strips out 'ActiveModel::Serializer::Adapter::'
        #   so that registering 'ActiveModel::Serializer::Adapter::Json' and
        #   'Json' will both register as 'json'.
        def register(name, klass = name)
          name = name.to_s.gsub(/\AActiveModel::Serializer::Adapter::/, ''.freeze)
          adapter_map.update(name.underscore => klass)
          self
        end

        # @param  adapter [String, Symbol, Class] name to fetch adapter by
        # @return [ActiveModel::Serializer::Adapter] subclass of Adapter
        # @raise  [UnknownAdapterError]
        def lookup(adapter)
          # 1. return if is a class
          return adapter if adapter.is_a?(Class)
          adapter_name = adapter.to_s.underscore
          # 2. return if registered
          adapter_map.fetch(adapter_name) do
            # 3. try to find adapter class from environment
            adapter_class = find_by_name(adapter_name)
            register(adapter_name, adapter_class)
            adapter_class
          end
        rescue NameError, ArgumentError => e
          failure_message =
            "NameError: #{e.message}. Unknown adapter: #{adapter.inspect}. Valid adapters are: #{adapters}"
          raise UnknownAdapterError, failure_message, e.backtrace
        end

        # @api private
        def find_by_name(adapter_name)
          adapter_name = adapter_name.to_s.classify.tr('API', 'Api')
          "ActiveModel::Serializer::Adapter::#{adapter_name}".safe_constantize ||
            "ActiveModel::Serializer::Adapter::#{adapter_name.pluralize}".safe_constantize or # rubocop:disable Style/AndOr
            fail UnknownAdapterError
        end
        private :find_by_name
      end

      # Gotta be at the bottom to use the code above it :(
      require 'active_model/serializer/adapter/base'
      require 'active_model/serializer/adapter/null'
      require 'active_model/serializer/adapter/attributes'
      require 'active_model/serializer/adapter/json'
      require 'active_model/serializer/adapter/json_api'
    end
  end
end

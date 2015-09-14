module ActiveModel
  class Serializer
    class Adapter
      UnknownAdapterError = Class.new(ArgumentError)
      ADAPTER_MAP = {}
      private_constant :ADAPTER_MAP if defined?(private_constant)
      extend ActiveSupport::Autoload
      autoload :FragmentCache
      autoload :Json
      autoload :JsonApi
      autoload :Null
      autoload :FlattenJson

      class << self
        def create(resource, options = {})
          override = options.delete(:adapter)
          klass = override ? adapter_class(override) : ActiveModel::Serializer.adapter
          klass.new(resource, options)
        end

        # @see ActiveModel::Serializer::Adapter.lookup
        def adapter_class(adapter)
          ActiveModel::Serializer::Adapter.lookup(adapter)
        end

        # Automatically register adapters when subclassing
        def inherited(subclass)
          ActiveModel::Serializer::Adapter.register(subclass.to_s.demodulize, subclass)
        end
      end

      # Only the Adapter class has these methods.
      # None of the sublasses have them.
      class << ActiveModel::Serializer::Adapter
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
        # @param [Symbol, String] name of the registered adapter
        # @param [Class] klass - adapter class itself
        # @example
        #     AMS::Adapter.register(:my_adapter, MyAdapter)
        def register(name, klass)
          adapter_map.update(name.to_s.underscore => klass)
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
          adapter_map.fetch(adapter_name) {
            # 3. try to find adapter class from environment
            adapter_class = find_by_name(adapter_name)
            register(adapter_name, adapter_class)
            adapter_class
          }
        rescue NameError, ArgumentError => e
          failure_message =
            "NameError: #{e.message}. Unknown adapter: #{adapter.inspect}. Valid adapters are: #{adapters}"
          raise UnknownAdapterError, failure_message, e.backtrace
        end

        # @api private
        def find_by_name(adapter_name)
          adapter_name = adapter_name.to_s.classify.tr('API', 'Api')
          ActiveModel::Serializer::Adapter.const_get(adapter_name.to_sym) or # rubocop:disable Style/AndOr
            fail UnknownAdapterError
        end
        private :find_by_name
      end

      attr_reader :serializer

      def initialize(serializer, options = {})
        @serializer = serializer
        @options = options
      end

      def serializable_hash(_options = nil)
        fail NotImplementedError, 'This is an abstract method. Should be implemented at the concrete adapter.'
      end

      def as_json(options = nil)
        hash = serializable_hash(options)
        include_meta(hash)
        hash
      end

      def fragment_cache(*_args)
        fail NotImplementedError, 'This is an abstract method. Should be implemented at the concrete adapter.'
      end

      private

      def cache_check(serializer)
        @cached_serializer = serializer
        @klass             = @cached_serializer.class
        if is_cached?
          @klass._cache.fetch(cache_key, @klass._cache_options) do
            yield
          end
        elsif is_fragment_cached?
          FragmentCache.new(self, @cached_serializer, @options).fetch
        else
          yield
        end
      end

      def is_cached?
        @klass._cache && !@klass._cache_only && !@klass._cache_except
      end

      def is_fragment_cached?
        @klass._cache_only && !@klass._cache_except || !@klass._cache_only && @klass._cache_except
      end

      def cache_key
        parts = []
        parts << object_cache_key
        parts << @klass._cache_digest unless @klass._cache_options && @klass._cache_options[:skip_digest]
        parts.join('/')
      end

      def object_cache_key
        object_time_safe = @cached_serializer.object.updated_at
        object_time_safe = object_time_safe.strftime('%Y%m%d%H%M%S%9N') if object_time_safe.respond_to?(:strftime)
        (@klass._cache_key) ? "#{@klass._cache_key}/#{@cached_serializer.object.id}-#{object_time_safe}" : @cached_serializer.object.cache_key
      end

      def meta
        serializer.meta if serializer.respond_to?(:meta)
      end

      def meta_key
        serializer.meta_key || 'meta'
      end

      def root
        serializer.json_key.to_sym if serializer.json_key
      end

      def include_meta(json)
        json[meta_key] = meta if meta
        json
      end
    end
  end
end

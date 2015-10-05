module ActiveModel
  class Serializer
    module Adapter
      class Base
        # Automatically register adapters when subclassing
        def self.inherited(subclass)
          ActiveModel::Serializer::Adapter.register(subclass)
        end

        attr_reader :serializer, :instance_options

        def initialize(serializer, options = {})
          @serializer = serializer
          @instance_options = options
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

        def cache_check(serializer)
          CachedSerializer.new(serializer).cache_check(self) do
            yield
          end
        end

        private

        def meta
          instance_options.fetch(:meta, nil)
        end

        def meta_key
          instance_options.fetch(:meta_key, 'meta'.freeze)
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
end

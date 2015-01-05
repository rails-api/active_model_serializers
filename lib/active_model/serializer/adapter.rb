module ActiveModel
  class Serializer
    class Adapter
      extend ActiveSupport::Autoload
      autoload :Json
      autoload :Null
      autoload :JsonApi

      attr_reader :serializer

      def initialize(serializer, options = {})
        @serializer = serializer
        @options = options
      end

      def serializable_hash(options = {})
        raise NotImplementedError, 'This is an abstract method. Should be implemented at the concrete adapter.'
      end

      def as_json(options = {})
        hash = serializable_hash(options)
        include_meta(hash)
      end

      def self.create(resource, options = {})
        override = options.delete(:adapter)
        klass = override ? adapter_class(override) : ActiveModel::Serializer.adapter
        klass.new(resource, options)
      end

      def self.adapter_class(adapter)
        "ActiveModel::Serializer::Adapter::#{adapter.to_s.classify}".safe_constantize
      end

      private

      def meta
        serializer.meta if serializer.respond_to?(:meta)
      end

      def meta_key
        serializer.meta_key || "meta"
      end

      def root
        serializer.root
      end

      def include_meta(json)
        json[meta_key] = meta if meta && root
        json
      end
    end
  end
end

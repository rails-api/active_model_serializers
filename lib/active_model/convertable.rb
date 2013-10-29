module ActiveModel
  module Convertable
    extend ActiveSupport::Concern

    included do
      class_attribute :_root_proc, :_key_proc

      self._key_proc  = ->(original) { original }
      self._root_proc = ->(original) { original }
    end

    module ClassMethods
      def camelize_keys!(first_letter = :lower)
        self._key_proc  = ->(original){ camelize_keys original, first_letter }
        self._root_proc = ->(original){ original.to_s.camelize(first_letter) }
      end

      def convert_keys(&proc)
        self._key_proc = proc
      end

      def camelize_keys(original, first_letter = :lower)
        original.each_with_object({}) do |(key,value), hash|
          hash.merge!(key.to_s.camelize(first_letter) => (value.is_a?(Hash) ? camelize_keys(value, first_letter) : value))
        end
      end

      def _convert_root(root)
        _root_proc.call(root)
      end

      def _convert_keys(original = {})
        _key_proc.call(original)
      end
    end

    def _convert_root(root)
      _root_proc.call(root)
    end

    def _convert_keys(original = {})
      _key_proc.call(original)
    end
  end
end

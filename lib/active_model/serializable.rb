require 'active_support/core_ext/object/to_json'

module ActiveModel
  # Enable classes to Classes including this module to serialize themselves by implementing a serialize method and an options method.
  #
  # Example:
  #
  #     require 'active_model_serializers'
  #
  #     class MySerializer
  #       include ActiveModel::Serializable
  #
  #       def initialize
  #         @options = {}
  #       end
  #
  #       attr_reader :options
  #
  #       def serialize
  #         { a: 1 }
  #       end
  #     end
  #
  #     puts MySerializer.new.to_json
  module Serializable
    def as_json(args={})
      if root = args[:root] || options[:root]
        options[:hash] = hash = {}
        options[:unique_values] = {}

        hash.merge!(root => serialize)
        include_meta hash
        hash
      else
        serialize
      end
    end

    private

    def include_meta(hash)
      hash[meta_key] = options[:meta] if options.has_key?(:meta)
    end

    def meta_key
      options[:meta_key].try(:to_sym) || :meta
    end
  end
end

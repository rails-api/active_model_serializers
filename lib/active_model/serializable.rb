module ActiveModel
  module Serializable
    def as_json(options={})
      if root = options.fetch(:root, json_key)
        hash = { root => serializable_object }

        merge_hash(hash, serializable_data)

        hash
      else
        serializable_object
      end
    end

    def serializable_data
      embedded_in_root_associations.tap do |hash|
        if respond_to?(:meta) && meta
          hash[meta_key] = meta
        end
      end
    end

    def embedded_in_root_associations
      {}
    end

    def merge_hash(destination, source)
      source.each_pair do |key, value|
        if destination[key].is_a?(Array)
          destination[key].concat(value)
        else
          destination[key] = value
        end
      end
    end
  end
end

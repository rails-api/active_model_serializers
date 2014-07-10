module ActiveModel
  module Serializable
    def as_json(options={})
      options = options.to_hash if options.respond_to?(:to_hash)
      if root = options.fetch(:root, json_key)
        hash = { root => serializable_object }
        hash.merge!(serializable_data)
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
  end
end

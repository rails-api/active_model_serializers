module ActiveModel
  module Serializable
    def as_json(options={})
      if root = options.fetch(:root, root_key)
        hash = { root => serializable_object }
        hash.merge!(serializable_data)
        hash
      else
        serializable_object
      end
    end
    alias serializable_hash as_json

    def as_xml(options={})
      root = options.fetch(:root, root_key)
      serializable_hash.to_xml(root: root)
    end
    alias to_xml as_xml

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

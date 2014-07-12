module ActiveModel
  module Serializable
    def as_json(options={})
      if root = options.fetch(:root, json_key)
        hash = { root => serializable_object }
        hash.merge!(serializable_data)
        hash
      else
        serializable_object
      end
    end

    def serializable_hash(options={})
      root = options.fetch(:root, xml_key)
      hash = { root => serializable_object }
      hash.merge!(serializable_data)
      hash
    end

    def as_xml(options={})
      hash = as_json

      # XML must have one and only one root
      if hash.size > 1 || !hash.is_a?(Hash)
        root = options.fetch(:root, xml_key)
        hash.to_xml(root: root)
      else
        root = hash.keys.first
        hash[root].to_xml(root: root)
      end
    end
    alias_method :to_xml, :as_xml

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

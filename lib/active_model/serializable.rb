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
    alias_method :serializable_hash, :as_json

    def as_xml(options={})
      # XML must have one and only one root
      if as_json.size > 1 || !as_json.is_a?(Hash)
        root = options.fetch(:xml_root, xml_root_key)
        as_json.to_xml(root: root)
      else
        root = as_json.keys.first
        as_json[root].to_xml(root: root)
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

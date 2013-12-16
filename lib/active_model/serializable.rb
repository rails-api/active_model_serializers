module ActiveModel
  module Serializable
    def as_json(options={})
			root = options.fetch(:root, json_key)
			root = apply_conversion(root) if @convert_type
      if root
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

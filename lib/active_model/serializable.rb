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
      if respond_to?(:meta) && meta
        { meta_key => meta }
      else
        {}
      end
    end
  end
end

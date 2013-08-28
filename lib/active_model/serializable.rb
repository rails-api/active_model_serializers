module ActiveModel
  module Serializable
    def as_json(options={})
      if root = options[:root] || self.root
        hash = { root.to_s => serializable_object }
        hash.merge!(serializable_data)
        hash
      else
        serializable_object
      end
    end

    def serializable_data
      if respond_to?(:meta) && meta
        { meta_key.to_s => meta }
      else
        {}
      end
    end
  end
end

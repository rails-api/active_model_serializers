module ActiveModel
  module Serializable
    def as_json(options={})
      if root = options[:root] || self.root
        hash = { root.to_s => serializable_object }
        hash[meta_key.to_s] = meta if meta
        hash
      else
        serializable_object
      end
    end
  end
end

module ActiveModel
  module Serializable
    def as_json(options={})
      if root = options.fetch(:root, json_key)
        hash = { root => serializable_object }

        serializable_data.each_pair do |key, value|
          if hash[key].is_a?(Array)
            hash[key].concat(value)
          else
            hash[key] = value
          end
        end

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

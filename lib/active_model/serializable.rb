require 'active_model/convertable'
module ActiveModel
  module Serializable
    extend ActiveSupport::Concern

    included do
      include Convertable
    end

    def as_json(options={})
      if root = options[:root] || self.root
        hash = { _convert_root(root) => serializable_object }
        hash.merge!(serializable_data)
        hash
      else
        serializable_object
      end
    end

    def serializable_data
      if respond_to?(:meta) && meta
        _convert_keys({ meta_key => meta })
      else
        {}
      end
    end
  end
end

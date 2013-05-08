module ActiveModel
  module Serializable
    def meta_key
      options[:meta_key].try(:to_sym) || :meta
    end

    def include_meta(hash)
      hash[meta_key] = options[:meta] if options.has_key?(:meta)
    end

    def as_json(*args)
      options[:hash] = hash = {}
      options[:unique_values] = {}

      if root = options[:root]
        hash.merge!(root => serialize)
        include_meta hash
        hash
      else
        serialize
      end
    end

    def to_json(*args)
      if perform_caching?
        cache.fetch expand_cache_key([self.class.to_s.underscore, cache_key, 'to-json']) do
          super
        end
      else
        super
      end
    end
  end
end

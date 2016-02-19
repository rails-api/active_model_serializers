module ActiveModel
  class Serializer
    module Adapter
      class FragmentCache
        attr_reader :serializer

        def initialize(adapter, serializer, options)
          @instance_options = options
          @adapter    = adapter
          @serializer = serializer
        end

        # 1. Create a CachedSerializer and NonCachedSerializer from the serializer class
        # 2. Serialize the above two with the given adapter
        # 3. Pass their serializations to the adapter +::fragment_cache+
        def fetch

        end

        protected

        attr_reader :instance_options, :adapter

        private





        def to_valid_const_name(name)
          name.gsub('::', '_')
        end
      end
    end
  end
end

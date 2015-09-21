module ActiveModel
  class Serializer
    class IncludeTree
      module Parsing
        module_function

        def include_string_to_hash(included)
          included.delete(' ').split(',').reduce({}) do |hash, path|
            include_tree = path.split('.').reverse_each.reduce({}) { |a, e| { e.to_sym => a } }
            hash.deep_merge!(include_tree)
          end
        end

        def include_args_to_hash(included)
          case included
          when Symbol
            { included => {} }
          when Hash
            included.each_with_object({}) do |(key, value), hash|
              hash[key] = include_args_to_hash(value)
            end
          when Array
            included.reduce({}) { |a, e| a.merge!(include_args_to_hash(e)) }
          when String
            include_string_to_hash(included)
          else
            {}
          end
        end
      end

      # Builds an IncludeTree from a comma separated list of dot separated paths (JSON API format).
      # @example `'posts.author, posts.comments.upvotes, posts.comments.author'`
      #
      # @param [String] included
      # @return [IncludeTree]
      #
      def self.from_string(included)
        new(Parsing.include_string_to_hash(included))
      end

      # Translates the arguments passed to the include option into an IncludeTree.
      # The format can be either a String (see #from_string), an Array of Symbols and Hashes, or a mix of both.
      # @example `posts: [:author, comments: [:author, :upvotes]]`
      #
      # @param [Symbol, Hash, Array, String] included
      # @return [IncludeTree]
      #
      def self.from_include_args(included)
        new(Parsing.include_args_to_hash(included))
      end

      # @param [Hash] hash
      def initialize(hash = {})
        @hash = hash
      end

      def key?(key)
        @hash.key?(key) || @hash.key?(:*) || @hash.key?(:**)
      end

      def [](key)
        # TODO(beauby): Adopt a lazy caching strategy for generating subtrees.
        case
        when @hash.key?(key)
          self.class.new(@hash[key])
        when @hash.key?(:*)
          self.class.new(@hash[:*])
        when @hash.key?(:**)
          self.class.new(:** => {})
        end
      end
    end
  end
end

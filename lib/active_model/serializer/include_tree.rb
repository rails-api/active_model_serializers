module ActiveModel
  class Serializer
    # TODO: description of this class, and overview of how it's used
    class IncludeTree
      module Parsing
        module_function

        # Translates a comma separated list of dot separated paths (JSON API format) into a Hash.
        #
        # @example
        #   `'posts.author, posts.comments.upvotes, posts.comments.author'`
        #
        #   would become
        #
        #   `{ posts: { author: {}, comments: { author: {}, upvotes: {} } } }`.
        #
        # @param [String] included
        # @return [Hash] a Hash representing the same tree structure
        def include_string_to_hash(included)
          # TODO: Needs comment walking through the process of what all this is doing.
          included.delete(' ').split(',').reduce({}) do |hash, path|
            include_tree = path.split('.').reverse_each.reduce({}) { |a, e| { e.to_sym => a } }
            hash.deep_merge!(include_tree)
          end
        end

        # Translates the arguments passed to the include option into a Hash. The format can be either
        # a String (see #include_string_to_hash), an Array of Symbols and Hashes, or a mix of both.
        #
        # @example
        #  `posts: [:author, comments: [:author, :upvotes]]`
        #
        #  would become
        #
        #   `{ posts: { author: {}, comments: { author: {}, upvotes: {} } } }`.
        #
        # @example
        #  `[:author, :comments => [:author]]`
        #
        #   would become
        #
        #   `{:author => {}, :comments => { author: {} } }`
        #
        # @param [Symbol, Hash, Array, String] included
        # @return [Hash] a Hash representing the same tree structure
        def include_args_to_hash(included)
          case included
          when Symbol
            { included => {} }
          when Hash
            included.each_with_object({}) do |(key, value), hash|
              hash[key] = include_args_to_hash(value)
            end
          when Array
            included.reduce({}) { |a, e| a.deep_merge!(include_args_to_hash(e)) }
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
        return included if included.is_a?(IncludeTree)

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
        else
          nil
        end
      end
    end
  end
end

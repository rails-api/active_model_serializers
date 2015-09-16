module ActiveModel::Serializer::Utils
  module_function

  # Translates a comma separated list of dot separated paths (JSONAPI format) into a Hash.
  # Example: `'posts.author, posts.comments.upvotes, posts.comments.author'` would become `{ posts: { author: {}, comments: { author: {}, upvotes: {} } } }`.
  #
  # @param [String] included
  # @return [Hash] a Hash representing the same tree structure
  def include_string_to_hash(included)
    included.delete(' ').split(',').inject({}) do |hash, path|
      hash.deep_merge!(path.split('.').reverse_each.inject({}) { |a, e| { e.to_sym => a } })
    end
  end

  # Translates the arguments passed to the include option into a Hash. The format can be either
  # a String (see #include_string_to_hash), an Array of Symbols and Hashes, or a mix of both.
  # Example: `posts: [:author, comments: [:author, :upvotes]]` would become `{ posts: { author: {}, comments: { author: {}, upvotes: {} } } }`.
  #
  # @param [Symbol, Hash, Array, String] included
  # @return [Hash] a Hash representing the same tree structure
  def include_args_to_hash(included)
    case included
    when Symbol
      { included => {} }
    when Hash
      included.each_with_object({}) { |(key, value), hash| hash[key] = include_args_to_hash(value) }
    when Array
      included.inject({}) { |a, e| a.merge!(include_args_to_hash(e)) }
    when String
      include_string_to_hash(included)
    else
      {}
    end
  end

  def nested_lookup_paths(klass)
    paths = klass.to_s.split('::').reverse.inject([]) { |a, e| a + [[e] + Array(a.last)] }.reverse
    paths.map! { |path| "::#{path.join('::')}" }
    paths.select! { |path| Object.const_defined?(path, false) }
    paths.map! { |path| Object.const_get(path) }
    paths.push(::Object)

    paths
  end
end

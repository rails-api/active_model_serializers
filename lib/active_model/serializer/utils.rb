module ActiveModel::Serializer::Utils
  module_function

  # Gives the existing lookup paths that are suffixes of the fully qualified path of `klass`.
  # @param [Object] klass
  # @return [Array<Symbol>]
  def nested_lookup_paths(klass)
    paths = klass.to_s.split('::').reverse.reduce([]) { |a, e| a + [[e] + Array(a.last)] }.reverse
    paths.map! { |path| "#{path.join('::')}" }
    paths.map! do |path|
      begin
        path.constantize
      rescue NameError
        nil
      end
    end
    paths.delete(nil)
    paths.push(Object)

    paths
  end

  # Gives the class named `class_name` if it exists (directly) inside one of the lookup `paths`.
  # @param [Array<Symbol>] paths
  # @param [Symbol, String] class_name
  # @return [Object, nil]
  def nested_lookup(paths, class_name)
    class_path = paths.find { |path| path.const_defined?(class_name, false) }
    class_path.const_get(class_name) if class_path
  end
end

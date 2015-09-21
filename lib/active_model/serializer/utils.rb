module ActiveModel::Serializer::Utils
  module_function

  def nested_lookup_paths(klass)
    paths = klass.to_s.split('::').reverse.reduce([]) { |a, e| a + [[e] + Array(a.last)] }.reverse
    paths.map! { |path| "#{path.join('::')}" }
    paths.select! { |path| Object.const_defined?(path, false) }
    paths.map! { |path| Object.const_get(path) }
    paths.push(Object)

    paths
  end

  def nested_lookup(paths, class_name)
    class_path = paths.find { |path| path.const_defined?(class_name, false) }
    class_path.const_get(class_name) if class_path
  end
end

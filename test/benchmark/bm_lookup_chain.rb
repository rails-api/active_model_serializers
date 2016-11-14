require_relative './benchmarking_support'
require_relative './app'

time = 10
disable_gc = true
ActiveModelSerializers.config.key_transform = :unaltered

configurable = lambda do
  Benchmark.ams('Configurable Lookup Chain', time: time, disable_gc: disable_gc) do
    ActiveModel::Serializer.serializer_lookup_chain_for(PrimaryResource)
  end
end

old = lambda do
  module ActiveModel
    class Serializer
      def self.serializer_lookup_chain_for(klass, namespace = nil)
        chain = []

        resource_class_name = klass.name.demodulize
        resource_namespace = klass.name.deconstantize
        serializer_class_name = "#{resource_class_name}Serializer"

        chain.push("#{namespace}::#{serializer_class_name}") if namespace
        chain.push("#{name}::#{serializer_class_name}") if self != ActiveModel::Serializer
        chain.push("#{resource_namespace}::#{serializer_class_name}")

        chain
      end
    end
  end

  Benchmark.ams('Old Lookup Chain (v0.10)', time: time, disable_gc: disable_gc) do
    ActiveModel::Serializer.serializer_lookup_chain_for(PrimaryResource)
  end
end

configurable.call
old.call

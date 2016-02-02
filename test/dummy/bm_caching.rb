require_relative './benchmarking_support'
require_relative './app'
include Benchmark::ActiveModelSerializers::TestMethods

Benchmark.ams("caching on: caching serializers") do
  request(:get, "/caching/on")
end
Benchmark.ams("caching off: caching serializers") do
  request(:get, "/caching/off")
end
Benchmark.ams("caching on: non-caching serializers") do
  request(:get, "/caching/on")
end
Benchmark.ams("caching off: non-caching serializers") do
  request(:get, "/caching/off")
end

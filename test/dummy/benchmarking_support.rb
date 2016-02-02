require 'benchmark'
require 'json'

module Benchmark
  module ActiveModelSerializers
    module TestMethods
      def request(method, path)
        response = Rack::MockRequest.new(DummyApp).send(method, path)
        if response.status.in?([404, 500])
          fail "omg, #{method}, #{path}, #{response.status}, #{response.body}"
        end
        response
      end
    end
    def ams(label=nil, time: 1_000, warmup: 10, &block)
      unless block_given?
        raise ArgumentError.new, "block should be passed"
      end

      # run_gc
      GC.enable
      GC.start
      GC.disable
      warmup.times do
        yield
      end
      measurement = Benchmark.measure do
        time.times do
          yield
        end
      end

      user = measurement.utime
      system = measurement.stime
      total = measurement.total
      real = measurement.real
      output = {
        label: label,
        real: real,
        total: total,
        user:  user,
        system: system,
        version: ::ActiveModel::Serializer::VERSION,
        total_allocated_objects_per_iteration: get_total_allocated_objects(&block)
      }.to_json

      puts output
    end

    def get_total_allocated_objects
      if block_given?
        key =
          if RUBY_VERSION < '2.2'
            :total_allocated_object
          else
            :total_allocated_objects
          end

        before = GC.stat[key]
        yield
        after = GC.stat[key]
        after - before
      end
    end
  end

  extend Benchmark::ActiveModelSerializers
end

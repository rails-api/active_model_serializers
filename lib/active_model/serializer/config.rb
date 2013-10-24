require 'thread'

module ActiveModel
  class Serializer
    class Config
      def initialize
        @data = {}
        @mutex = Mutex.new
      end

      def each(&block)
        @mutex.synchronize do
          @data.each(&block)
        end
      end

      def clear
        @mutex.synchronize do
          @data.clear
        end
      end

      def method_missing(name, *args)
        @mutex.synchronize do
          name = name.to_s
          return @data[name] if @data.include?(name)
          match = name.match(/\A(.*?)([?=]?)\Z/)
          case match[2]
          when "="
            @data[match[1]] = args.first
          when "?"
            !!@data[match[1]]
          end
        end
      end
    end

    CONFIG = Config.new
    CONFIG.embed = :objects
  end
end

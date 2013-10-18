module ActiveModel
  class Serializer
    class Settings
      def initialize
        @data = {}
      end

      def [](key)
        @data[key.to_s]
      end

      def []=(key, value)
        @data[key.to_s] = value
      end

      def each(&block)
        @data.each(&block)
      end

      def clear
        @data.clear
      end
    end

    SETTINGS = Settings.new
  end
end

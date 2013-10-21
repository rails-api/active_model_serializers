require 'active_support/hash_with_indifferent_access'

module ActiveModel
  class Serializer
    class Settings
      def initialize
        @data = ActiveSupport::HashWithIndifferentAccess.new
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end

      def each(&block)
        @data.each(&block)
      end

      def clear
        @data.clear
      end

      def method_missing(name, *args)
        return @data[name] if @data.include?(name)
        match = name.to_s.match(/(.*?)([?=]?)$/)
        case match[2]
        when "="
          @data[match[1]] = args.first
        when "?"
          !!@data[match[1]]
        end
      end
    end

    SETTINGS = Settings.new
  end
end

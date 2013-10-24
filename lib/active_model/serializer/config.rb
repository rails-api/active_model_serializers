module ActiveModel
  class Serializer
    class Config
      def initialize(data = {})
        @data = data
      end

      def each(&block)
        @data.each(&block)
      end

      def clear
        @data.clear
      end

      def method_missing(name, *args)
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

    CONFIG = Config.new('embed' => :objects) # :nodoc:
  end
end

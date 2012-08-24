module ActiveModel

  class OrderedSet
    def initialize(array)
      @array = array
      @hash = {}

      array.each do |item|
        @hash[item] = true
      end
    end

    def merge!(other)
      other.each do |item|
        next if @hash.key?(item)

        @hash[item] = true
        @array.push item
      end
    end

    def to_a
      @array
    end
  end

end
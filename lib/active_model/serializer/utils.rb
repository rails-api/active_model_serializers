module ActiveModel::Serializer::Utils
  module_function

    # converts the include hash to a standard format
    # for constrained serialization recursion
    #
    # converts
    #  [:author, :comments => [:author]] to
    #  {:author => [], :comments => [:author]}
    #
    # and
    #  [:author, :comments => {:author => :bio}, :posts => [:comments]] to
    #  {:author => [], :comments => {:author => :bio}, :posts => [:comments]}
    #
    # The data passed in to this method should be an array where the last
    # parameter is a hash
    #
    # the point of this method is to normalize the include
    # options for the child relationships.
    # if a sub inclusion is still an array after this method,
    # it will get converted during the next iteration
    def include_array_to_hash(include_array)
      # still don't trust input
      # but this also allows
      #  include: :author syntax
      include_array = Array[*include_array].compact

      result = {}

      hashes = include_array.select{|a| a.is_a?(Hash)}
      non_hashes = include_array - hashes

      hashes += non_hashes.map{ |association_name| { association_name => [] } }

      # now merge all the hashes
      hashes.each{|hash| result.merge!(hash) }

      result
    end


end

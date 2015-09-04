require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            @result = serialize_array_without_root(serializer, options)
          else
            @result = resource_object_for(serializer)
            @result = add_resource_relationships(
              @result,
              serializer,
              serializer.options[:include])


            @result
          end

          { root => @result }
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

        private

        # iterate through the associations on the serializer,
        # adding them to the parent as needed (as singular or plural)
        #
        # nested_associations is a list of symbols that governs what
        # associations on the passed in seralizer to include
        def add_resource_relationships(parent, serializer, nested_associations = [])
          # have the include array normalized
          nested_associations = include_array_to_hash(nested_associations)

          included_associations = if nested_associations.present?
            serializer.associations.select{ |association|
              # nested_associations is a hash of:
              #   key => nested association to include
              nested_associations.keys.include?(association.name)
            }
          else
            serializer.associations
          end

          included_associations.each do |association|
            serializer = association.serializer
            opts = association.options
            key = association.key

            # sanity check if the association has nesting data
            has_nesting = nested_associations[key].present?
            if has_nesting
              include_options_from_parent = { include: nested_associations[key] }
              opts = opts.merge(include_options_from_parent)
            end

            if serializer.respond_to?(:each)
              parent[key] = add_relationships(serializer, opts)
            else
              parent[key] = add_relationship(serializer, opts)
            end
          end

          parent
        end

        # add a singular relationship
        # the options should always belong to the serializer
        def add_relationship(serializer, options)
          serialized_relationship = serialized_or_virtual_of(serializer, options)

          nested_associations_to_include = options[:include]
          if nested_associations_to_include.present?
            serialized_relationship = add_resource_relationships(
              serialized_relationship,
              serializer,
              nested_associations_to_include)
          end

          serialized_relationship
        end

        # add a many relationship
        def add_relationships(serializer, options)
          serialize_array(serializer, options) do |serialized_item, item_serializer|
            nested_associations_to_include = options[:include]

            if nested_associations_to_include.present?
              serialized_item = add_resource_relationships(
                serialized_item,
                item_serializer,
                nested_associations_to_include)
            end

            serialized_item
          end
        end


        def serialize_array_without_root(serializer, options)
          serializer.map { |s| FlattenJson.new(s).serializable_hash(options) }
        end

        # a virtual value is something that doesn't need a serializer,
        # such as a ruby array, or any other raw value
        def serialized_or_virtual_of(serializer, options)
          if serializer && serializer.object
            resource_object_for(serializer)
          elsif options[:virtual_value]
            options[:virtual_value]
          end
        end

        def serialize_array(serializer, options)
          serializer.map do |item|
            serialized_item = resource_object_for(item)
            serialized_item = yield(serialized_item, item) if block_given?
            serialized_item
          end
        end

        def resource_object_for(serializer)
          cache_check(serializer) do
            serializer.attributes(serializer.options)
          end
        end

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
    end
  end
end

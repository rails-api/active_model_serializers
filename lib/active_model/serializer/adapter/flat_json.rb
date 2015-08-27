module ActiveModel
  class Serializer
    module Adapter
            class FlatJson < Base

              # the list of what has already been serialized will be kept here to
              # help avoid infinite recursion
              #
              # this should be a list of association_name to a list of objects
              attr_accessor :serialized

              # When we are sideloading associations, we can more easily track what
              # has been serialized, so that we avoid infinite
              # recursion / serialization.
              def initialize(*args)
                @serialized = {}

                super(*args)
              end

              def serializable_hash(options = nil)
                options ||= {}

                # begin recursive serialization
                # TODO: this will evaluate ALL specified relationships
                # throughout the entire tree.
                #
                # Do we want a way to limit this?
                serialize_hash(options)

                singularize_lone_objects

                @serialized
              end


              def serialize_hash(options)
                result = {}

                if serializer.respond_to?(:each)
                  # TODO: Is this ever hit?
                  result = serialize_array(serializer, options)
                else
                  # skip if we are already serialized
                  key_name = serializer.object.class.name.tableize
                  existing_of_kind = @serialized[key_name]
                  exists = existing_of_kind ? existing_of_kind.select{|a| a[:id] == s.object.id } : false
                  return if exists

                  # we aren't an array! woo!
                  result = serialized_attributes_of(serializer, options)
                  if result.nil?
                    puts serializer
                    puts options
                  end
                  # now, go over our associations, and add them to the master
                  # serialized hash
                  serializer.associations.each do |association|
                    serializer = association.serializer
                    opts = association.options

                    # make sure the association key exists in the master
                    # serialized hash
                    @serialized[association.key] ||= []

                    if serializer.respond_to?(:each)
                      array = serialize_array(serializer, opts)
                      association_list = @serialized[association.key]

                      # ensure that we don't add duplicates
                      array.each do |item|
                        if not association_list.include?(item)
                          association_list << item
                        end
                      end

                      # re-set the list for this model
                      @serialized[association.key] = association_list

                      # add the ids to the result
                      result[ids_name_for(association.key)] = array.map{|a| a[:id] }
                    else
                      hash = serialized_or_virtual_object(serializer, options)
                      add(association.key, hash)

                      # add the id to the result
                      result[id_name_for(association.key)] = hash[:id]
                    end

                  end
                end

                # add to the list of the serialized
                @serialized[key_name] ||= []
                add(key_name, result)

                result
              end

              def serialized_or_virtual_object(serializer, options)
                return options[:virtual_value] if options[:virtual_value]

                if serializer && serializer.object
                  serialized_attributes_of(serializer, options)
                end
              end

              def add(key, data)
                unless associations_contain?(data, key)
                  if @serialized[key].is_a?(Hash)
                    # make array
                    value = @serialized[key]
                    @serialized[key] = [value, data]
                  else
                    # already is array
                    @serialized[key] << data
                  end
                end
              end

              def serialize_array(serializer, options)
                array = serializer.map { |s|
                  js = FlatJson.new(s)
                  serialized = js.serialize_hash(options)

                  # keep the associations up to date
                  append_to_serialized(js.serialized)

                  serialized
                }

                # remove nils
                array.compact
              end

              def ids_name_for(name)
                id_name_for(name).to_s.pluralize.to_sym
              end

              def id_name_for(name)
                name.to_s.singularize.foreign_key.to_sym
              end


              def serialized_attributes_of(item, options)
                cache_check(item) do
                  item.attributes(options)
                end
              end

              # To make keeping track of serialized objects easier,
              # they are all tracked in arrays with plural keys.
              #
              # Once the recursion is done, we don't need plural keys / arrays
              # for singular objects.
              #
              # This method converts:
              #   objects: [{data}]
              #   #  to
              #   object: {data}
              #
              # This modifies and returns @serialized
              def singularize_lone_objects
                temp = {}

                @serialized.each do |key, data|
                  if data.length > 1
                    temp[key.to_s.pluralize.to_sym] = data
                  else
                    temp[key.to_s.singularize.to_sym] = data.first
                  end
                end

                @serialized = temp
              end

              # adds a set of objects to the @serialized structure,
              # while checking to make sure that a particular object
              # isn't already tracked.
              def append_to_serialized(serialized_objects)
                serialized_objects ||= {}

                serialized_objects.each do |association_name, data|
                  @serialized[association_name] ||= []

                  if data.is_a?(Array)
                    data.each do |sub_data|
                      append_to_serialized(association_name => sub_data)
                    end
                  else
                    unless associations_contain?(data, association_name)
                      add(association_name, data)
                    end
                  end
                end

                @serialized
              end

              def associations_contain?(item, key)
                return false if @serialized[key].nil?

                @serialized[key] == item || @serialized[key].include?(item)
              end

            end
    end
  end
end

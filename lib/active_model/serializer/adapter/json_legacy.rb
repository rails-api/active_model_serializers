require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class JsonLegacy < Adapter
        attr_reader :associations

        def initialize(serializer, options = {})
          @associations = options[:associations] || {}
          super(serializer, options)
        end

        def serializable_hash(options = {})
          @output = {}
          if serializer.respond_to?(:each)
            data = serializer.map do |s|
              JsonLegacy.new(s, options.merge(associations: associations)).process_attributes(options)
            end
          else
            data = process_attributes(options)
          end
          # Split the root incase of namespaced models.
          { root.to_s.split("/").last => data }.merge(associations)
        end

        def process_attributes(options = {})
          keys = cache_check(serializer) do
            serializer.attributes(options_with_filtered_fields(serializer, options))
          end

          keys.merge(process_associations)
        end

        def process_associations
          keys = {}
          serializer.associations.each do |association|
            name = association.name
            opts = association.options
            association_serializer = association.serializer
            next unless filtered_fields(serializer, opts).include?(name.to_sym)

            # Create empty array as per 0.9
            opts[:root] ||= opts[:serializer].root_name.pluralize if opts[:serializer]
            associations[opts[:root]] ||= {}

            if association_serializer.respond_to?(:each)
              key = opts[:key] || "#{name.to_s.singularize}_ids"
              keys[key] = association_serializer.map(&:id)
              association_serializer.each do |associated_serializer|
                add_associated_object(associated_serializer, opts)
              end
            else
              key = opts[:key] || "#{name}_id"
              if association_serializer && association_serializer.object
                keys[key] = association_serializer.id
                add_associated_object(association_serializer, opts)
              elsif opts[:virtual_value]
                keys[key] = opts[:virtual_value]
              else
                keys[key] = nil
              end
            end
          end
          keys
        end

        def add_associated_object(associated_serializer, options)
          return unless associated_serializer
          key = options[:root] || associated_serializer.object.model_name.collection
          associations[key] ||= {}
          unless associations[key][associated_serializer.id]
            adapter = JsonLegacy.new(associated_serializer, options.merge(associations: associations))
            associations[key][associated_serializer.id] = adapter.process_attributes(options)
          end
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

        def options_with_filtered_fields(serializer, options)
          options[:fields] = filtered_fields(serializer, options)
          options
        end

        def filtered_fields(serializer, options)
          @filtered_fields ||= {}
          @filtered_fields[serializer] ||= options[:fields] || (serializer.respond_to?(:filter) ? serializer.filter(default_fields(serializer)) : default_fields(serializer))
        end

        def default_fields(serializer)
          serializer.class._attributes + serializer.associations.map(&:name).map(&:to_sym)
        end
      end
    end
  end
end

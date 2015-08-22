module ActiveModel
  class Serializer
    class Adapter
      class CollectionJson < Adapter
        def initialize(serializer, options = {})
          super
          @hash = {}
        end

        def serializable_hash(options = {})
          @hash[:version] = "1.0"
          @hash[:href] = add_href(:collection)

          add_items

          { collection: @hash }
        end

        private

        def add_items
          if serializer.respond_to?(:each)
            serializer.map do |serializer|
              add_item(serializer)
            end
          else
            add_item(serializer)
          end
        end

        def add_item(serializer)
          @hash.store :items, [] unless @hash.key?(:items)
          item = Hash.new

          item[:href] = add_href(:item, serializer.object)

          serializer.attributes.each do |k,v|
            item[:data] = [] unless item.key?(:data)

            c = { name: k.to_s, value: v }
            item[:data] << c
          end if serializer.attributes.present?

          @hash[:items] << item
        end

        def add_href(target = :collection, object = nil)
          case target
          when :collection
            Rails.application.routes.url_helpers.send("#{type.pluralize}_url")
          when :item
            Rails.application.routes.url_helpers.send("#{type}_url", object)
          end
        end

        # This is copy&paste from the JsonApi adapter
        # Should it be moved to AMS::Adapter?
        def serialized_object_type(serializer)
          return false unless Array(serializer).first
          type_name = Array(serializer).first.object.class.to_s.underscore
          if serializer.respond_to?(:first)
            type_name.pluralize
          else
            type_name
          end
        end

        def type
          serialized_object_type(serializer).singularize
        end
      end
    end
  end
end

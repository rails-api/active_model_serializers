module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        module Deserialization
          module_function

          # Parse a Hash or ActionController::Parameters representing a JSON API document
          # into an ActiveRecord-ready hash.
          #
          # @param [Hash|Object implementing `to_h`] document
          # @param [Hash] options
          #   fields: Array of symbols and a Hash. Specify whitelisted fields, optionally
          #     specifying the attribute name on the model.
          # @return [Hash] ActiveRecord-ready hash
          #
          def parse(document, options = {})
            fields = parse_fields(options[:fields])

            hash = {}

            document = document.to_h unless document.is_a?(Hash)
            primary_data = document.fetch('data', {})
            included_data = document.fetch('included', {})

            hash.merge!(parse_primary_data(primary_data, fields))
            hash.merge!(parse_included_data(included_data, fields))

            hash
          end

          def parse_included_data(included_data, fields)
            data = {}
            included_data.each do |included_resource|
              parsed = parse_primary_data(included_resource, fields)
              # parsed should only have one key
              # so there is no possibility of missing other keys when
              # calling first
              # NOTE: key is always going to be singular
              key = parsed.keys.first
              plural_key = key.pluralize
              parsed_attributes = parsed[key]
              # on multiple iterations of parsing the same type
              # the key in data is changed to be plural,
              # so we need to check for the existence of both
              # singular and plural keys
              exists = data.keys.include?(key) || data.keys.include?(plural_key)

              if exists
                old_data = data[key] || data[plural_key]
                if old_data.is_a?(Hash)
                  data.delete(key)
                  data[plural_key] = [old_data, parsed_attributes]
                elsif old_data.is_a?(Array)
                  data[plural_key] << parsed_attributes
                end
              else
                data.merge! parsed
              end
            end

            puts '--------------------------'
            puts data
            puts '----------------------------'
            data
          end

          def parse_primary_data(primary_data, fields)
            data = {}
            type = primary_data['type']
            data[:id] = primary_data['id'] if primary_data['id'] && (fields.nil? || fields[:id])
            data.merge!(parse_attributes(primary_data['attributes'], fields))
            data.merge!(parse_relationships(primary_data['relationships'], fields))

            { type.singularize => data }
          end

          # @api private
          def parse_fields(fields)
            return nil unless fields.is_a?(Array)
            fields.each_with_object({}) do |attr, hash|
              if attr.is_a?(Symbol)
                hash[attr] = attr
              elsif attr.is_a?(Hash)
                hash.merge!(attr)
              end
            end
          end

          # @api private
          def parse_attributes(attributes, fields)
            return {} unless attributes
            attributes.each_with_object({}) do |(key, value), hash|
              attribute_name = fields ? fields[key.to_sym] : key.to_sym
              next unless attribute_name
              hash[attribute_name] = value
            end
          end

          # @api private
          def parse_relationships(relationships, fields)
            return {} unless relationships
            relationships.each_with_object({}) do |(key, value), hash|
              association_name = fields ? fields[key.to_sym] : key.to_sym
              next unless association_name
              data = value['data']
              if data.is_a?(Array)
                key = "#{association_name.to_s.singularize.to_sym}_ids".to_sym
                hash[key] = data.map { |ri| ri['id'] }
              else
                key = "#{association_name}_id".to_sym
                hash[key] = data ? data['id'] : nil
              end
            end
          end
        end
      end
    end
  end
end

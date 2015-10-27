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
            hash[:id] = primary_data['id'] if primary_data['id'] && (fields.nil? || fields[:id])

            hash.merge!(parse_attributes(primary_data['attributes'], fields))
            hash.merge!(parse_relationships(primary_data['relationships'], fields))

            hash
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

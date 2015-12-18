module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        module ApiObjects
          module JsonApiObject
            ActiveModel::Serializer.config.jsonapi_version = '1.0'
            ActiveModel::Serializer.config.jsonapi_toplevel_meta = {}
            # Make JSON API top-level jsonapi member opt-in
            # ref: http://jsonapi.org/format/#document-top-level
            ActiveModel::Serializer.config.jsonapi_include_toplevel_object = false

            module_function

            def add!(hash)
              hash.merge!(object) if include_object?
            end

            def include_object?
              ActiveModel::Serializer.config.jsonapi_include_toplevel_object
            end

            # TODO: see if we can cache this
            def object
              object = {
                jsonapi: {
                  version: ActiveModel::Serializer.config.jsonapi_version,
                  meta: ActiveModel::Serializer.config.jsonapi_toplevel_meta
                }
              }
              object[:jsonapi].reject! { |_, v| v.blank? }

              object
            end
          end
        end
      end
    end
  end
end

module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      # {http://jsonapi.org/format/#document-jsonapi-object Jsonapi Object}
      module Jsonapi
        module_function

        def add!(hash)
          hash.merge!(object) if include_object?
        end

        def include_object?
          ActiveModelSerializers.config.jsonapi_include_toplevel_object
        end

        # TODO: see if we can cache this
        def object
          object = {
            jsonapi: {
              version: ActiveModelSerializers.config.jsonapi_version,
              meta: ActiveModelSerializers.config.jsonapi_toplevel_meta
            }
          }
          object[:jsonapi].reject! { |_, v| v.blank? }

          object
        end
      end
    end
  end
end

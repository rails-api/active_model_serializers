[Back to Guides](../README.md)

# Configuration Options

The following configuration options can be set on `ActiveModelSerializers.config`,
preferably inside an initializer.

## General

- `adapter`: The [adapter](adapters.md) to use. Possible values: `:attributes, :json, :json_api`. Default: `:attributes`.
- `serializer_lookup_enabled`: When `false`, serializers must be explicitly specified. Default: `true`

## JSON API

- `jsonapi_resource_type`: Whether the `type` attributes of resources should be singular or plural. Possible values: `:singular, :plural`. Default: `:plural`.
- `jsonapi_include_toplevel_object`: Whether to include a [top level JSON API member](http://jsonapi.org/format/#document-jsonapi-object)
   in the response document.
   Default: `false`.
- Used when `jsonapi_include_toplevel_object` is `true`:
  - `jsonapi_version`: The latest version of the spec the API conforms to.
    Default: `'1.0'`.
  - `jsonapi_toplevel_meta`: Optional metadata. Not included if empty.
    Default: `{}`.

## Hooks

To run a hook when ActiveModelSerializers is loaded, use `ActiveSupport.on_load(:action_controller) do end`

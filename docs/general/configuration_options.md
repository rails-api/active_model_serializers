# Configuration Options

The following configuration options can be set on `ActiveModel::Serializer.config` inside an initializer.

## General

- `adapter`: The [adapter](adapters.md) to use. Possible values: `:attributes, :json, :json_api`. Default: `:attributes`.
- `automatic_lookup`: Whether serializer should be automatically looked up or manually provided. Default: `true`

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

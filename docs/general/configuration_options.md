# Configuration Options

The following configuration options can be set on `ActiveModel::Serializer.config` inside an initializer.

## General

- `adapter`: The [adapter](adapters.md) to use. Possible values: `:flatten_json, :json, :json_api`. Default: `:flatten_json`.

## JSON API

- `jsonapi_resource_type`: Whether the `type` attributes of resources should be singular or plural. Possible values: `:singular, :plural`. Default: `:plural`.
- `jsonapi_toplevel_member`: Whether to include a [top level JSON API member](http://jsonapi.org/format/#document-jsonapi-object) in the response document. Default: `false`.
- `jsonapi_version`: The latest version of the spec the API conforms to. Used when `jsonapi_toplevel_member` is `true`. Default: `'1.0'`.

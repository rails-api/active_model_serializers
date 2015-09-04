# Configuration Options

The following configuration options can be set on `ActiveModel::Serializer.config` inside an initializer.

## General

- `adapter`: The [adapter](adapters.md) to use. Possible values: `:attributes, :json, :json_api`. Default: `:attributes`.

## JSON API

- `jsonapi_resource_type`: Whether the `type` attributes of resources should be singular or plural. Possible values: `:singular, :plural`. Default: `:plural`.

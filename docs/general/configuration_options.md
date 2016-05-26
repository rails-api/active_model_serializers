[Back to Guides](../README.md)

# Configuration Options

The following configuration options can be set on
`ActiveModelSerializers.config`, preferably inside an initializer.

## General

##### adapter

The [adapter](adapters.md) to use.

Possible values:

- `:attributes` (default)
- `:json`
- `:json_api`

##### serializer_lookup_enabled

Enable automatic serializer lookup.

Possible values:

- `true` (default)
- `false`

When `false`, serializers must be explicitly specified.

##### key_transform

The [key transform](key_transforms.md) to use.


| Option | Result |
|----|----|
| `:camel` | ExampleKey |
| `:camel_lower` | exampleKey |
| `:dash` | example-key |
| `:unaltered` | the original, unaltered key |
| `:underscore` | example_key |
| `nil` | use the adapter default |

Each adapter has a default key transform configured:

| Adapter | Default Key Transform |
|----|----|
| `Json` | `:unaltered` |
| `JsonApi` | `:dash` |

`config.key_transform` is a global override of the adapter default. Adapters
still prefer the render option `:key_transform` over this setting.

*NOTE: Key transforms can be expensive operations. If key transforms are unnecessary for the
application, setting `config.key_transform` to `:unaltered` will provide a performance boost.*

##### default_includes
What relationships to serialize by default.  Default: `'*'`, which includes one level of related
objects. See [includes](adapters.md#included) for more info.

## JSON API

##### jsonapi_resource_type

Sets whether the [type](http://jsonapi.org/format/#document-resource-identifier-objects)
of the resource should be `singularized` or `pluralized` when it is not
[explicitly specified by the serializer](https://github.com/rails-api/active_model_serializers/blob/master/docs/general/serializers.md#type)

Possible values:

- `:singular`
- `:plural` (default)

##### jsonapi_include_toplevel_object

Include a [top level jsonapi member](http://jsonapi.org/format/#document-jsonapi-object)
in the response document.

Possible values:

- `true`
- `false` (default)

##### jsonapi_version

The latest version of the spec to which the API conforms.

Default: `'1.0'`.

*Used when `jsonapi_include_toplevel_object` is `true`*

##### jsonapi_toplevel_meta

Optional top-level metadata. Not included if empty.

Default: `{}`.

*Used when `jsonapi_include_toplevel_object` is `true`*


## Hooks

To run a hook when ActiveModelSerializers is loaded, use
`ActiveSupport.on_load(:action_controller) do end`

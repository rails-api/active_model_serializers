[Back to Guides](../README.md)

# Key Transforms

Key transforms modify the keys in serialized responses.

Provided key transforms:

- `:camel` - ExampleKey
- `:camel_lower` - exampleKey
- `:dashed` - example-key
- `:unaltered` - the original, unaltered key
- `nil` - use the adapter default

Key translation precedence is as follows:

##### SerializableResource option

`key_transform` is provided as an option via render.

```render json: posts, each_serializer: PostSerializer, key_transform: :camel_lower```

##### Configuration option

`key_transform` is set in `ActiveModelSerializers.config.key_transform`.

```ActiveModelSerializers.config.key_transform = :camel_lower```

##### Adapter default

Each adapter has a default key transform configured:

- `Json` - `:unaltered`
- `JsonApi` - `:dashed`

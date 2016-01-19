[Back to Guides](../README.md)

# Adapters

ActiveModelSerializers offers the ability to configure which adapter
to use both globally and/or when serializing (usually when rendering).

The global adapter configuration is set on [`ActiveModelSerializers.config`](configuration_options.md).
It should be set only once, preferably at initialization.

For example:

```ruby
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
```

or

```ruby
ActiveModel::Serializer.config.adapter = :json_api
```

or

```ruby
ActiveModel::Serializer.config.adapter = :json
```

The local adapter option is in the format `adapter: adapter`, where `adapter` is
any of the same values as set globally.

The configured adapter can be set as a symbol, class, or class name, as described in
[Advanced adapter configuration](adapters.md#advanced-adapter-configuration).

The `Attributes` adapter does not include a root key. It is just the serialized attributes.

Use either the `JSON` or `JSON API` adapters if you want the response document to have a root key.

## Built in Adapters

### Attributes - Default

It's the default adapter, it generates a json response without a root key.
Doesn't follow any specific convention.

### JSON

The response document always with a root key.

The root key **can't be overridden**, and will be derived from the resource being serialized.

Doesn't follow any specific convention.

### JSON API

This adapter follows **version 1.0** of the [format specified](../jsonapi/schema.md) in
[jsonapi.org/format](http://jsonapi.org/format).

#### Included

It will include the associated resources in the `"included"` member
when the resource names are included in the `include` option.
Including nested associated resources is also supported.

```ruby
  render json: @posts, include: ['author', 'comments', 'comments.author']
  # or
  render json: @posts, include: 'author,comments,comments.author'
```

In addition, two types of wildcards may be used:

- `*` includes one level of associations.
- `**` includes all recursively.

These can be combined with other paths.

```ruby
  render json: @posts, include: '**' # or '*' for a single layer
```

The format of the `include` option can be either:

- a String composed of a comma-separated list of [relationship paths](http://jsonapi.org/format/#fetching-includes).
- an Array of Symbols and Hashes.
- a mix of both.

The following would render posts and include:

- the author
- the author's comments, and
- every resource referenced by the author's comments (recursively).

It could be combined, like above, with other paths in any combination desired.

```ruby
  render json: @posts, include: 'author.comments.**'
```

##### Security Considerations

Since the included options may come from the query params (i.e. user-controller):

```ruby
  render json: @posts, include: params[:include]
```

The user could pass in `include=**`.

We recommend filtering any user-supplied includes appropriately.

## Advanced adapter configuration

### Registering an adapter

The default adapter can be configured, as above, to use any class given to it.

An adapter may also be specified, e.g. when rendering, as a class or as a symbol.
If a symbol, then the adapter must be, e.g. `:great_example`,
`ActiveModel::Serializer::Adapter::GreatExample`, or registered.

There are two ways to register an adapter:

1) The simplest, is to subclass `ActiveModel::Serializer::Adapter`, e.g. the below will
register the `Example::UsefulAdapter` as `:useful_adapter`.

```ruby
module Example
  class UsefulAdapter < ActiveModel::Serializer::Adapter
  end
end
```

You'll notice that the name it registers is the class name underscored, not the full namespace.

Under the covers, when the `ActiveModel::Serializer::Adapter` is subclassed, it registers
the subclass as `register(:useful_adapter, Example::UsefulAdapter)`

2) Any class can be registered as an adapter by calling `register` directly on the
`ActiveModel::Serializer::Adapter` class. e.g., the below registers `MyAdapter` as
`:special_adapter`.

```ruby
class MyAdapter; end
ActiveModel::Serializer::Adapter.register(:special_adapter, MyAdapter)
```

### Looking up an adapter

| Method | Return value |
| :------------ |:---------------|
| `ActiveModel::Serializer::Adapter.adapter_map` | A Hash of all known adapters `{ adapter_name => adapter_class }` |
| `ActiveModel::Serializer::Adapter.adapters` | A (sorted) Array of all known `adapter_names` |
| `ActiveModel::Serializer::Adapter.lookup(name_or_klass)` |  The `adapter_class`, else raises an `ActiveModel::Serializer::Adapter::UnknownAdapter` error |
| `ActiveModel::Serializer::Adapter.adapter_class(adapter)` | Delegates to `ActiveModel::Serializer::Adapter.lookup(adapter)` |
| `ActiveModel::Serializer.adapter` | A convenience method for `ActiveModel::Serializer::Adapter.lookup(config.adapter)` |

The registered adapter name is always a String, but may be looked up as a Symbol or String.
Helpfully, the Symbol or String is underscored, so that `get(:my_adapter)` and `get("MyAdapter")`
may both be used.

For more information, see [the Adapter class on GitHub](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model/serializer/adapter.rb)

[Back to Guides](../README.md)

# Adapters

ActiveModelSerializers offers the ability to configure which adapter
to use both globally and/or when serializing (usually when rendering).

The global adapter configuration is set on [`ActiveModelSerializers.config`](configuration_options.md).
It should be set only once, preferably at initialization.

For example:

```ruby
ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi
```

or

```ruby
ActiveModelSerializers.config.adapter = :json_api
```

or

```ruby
ActiveModelSerializers.config.adapter = :json
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

##### Example output

```json
{
  "title": "Title 1",
  "body": "Body 1",
  "publish_at": "2020-03-16T03:55:25.291Z",
  "author": {
    "first_name": "Bob",
    "last_name": "Jones"
  },
  "comments": [
    {
      "body": "cool"
    },
    {
      "body": "awesome"
    }
  ]
}
```

### JSON

The response document always with a root key.

The root key **can't be overridden**, and will be derived from the resource being serialized.

Doesn't follow any specific convention.

##### Example output

```json
{
  "post": {
    "title": "Title 1",
    "body": "Body 1",
    "publish_at": "2020-03-16T03:55:25.291Z",
    "author": {
      "first_name": "Bob",
      "last_name": "Jones"
    },
    "comments": [{
      "body": "cool"
    }, {
      "body": "awesome"
    }]
  }
}
```

### JSON API

This adapter follows **version 1.0** of the [format specified](../jsonapi/schema.md) in
[jsonapi.org/format](http://jsonapi.org/format).

##### Example output

```json
{
  "data": {
    "id": "1337",
    "type": "posts",
    "attributes": {
      "title": "Title 1",
      "body": "Body 1",
      "publish-at": "2020-03-16T03:55:25.291Z"
    },
    "relationships": {
      "author": {
        "data": {
          "id": "1",
          "type": "authors"
        }
      },
      "comments": {
        "data": [{
          "id": "7",
          "type": "comments"
        }, {
          "id": "12",
          "type": "comments"
        }]
      }
    },
    "links": {
      "post-authors": "https://example.com/post_authors"
    },
    "meta": {
      "rating": 5,
      "favorite-count": 10
    }
  }
}
```

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

#### Excluded

Sometimes you want to omit a specific field or association during serialization.
You can use the `except` option for this:

```ruby
  render json: @posts, include: '*', except: :author
```

This is particularly helpful if you are using the recursive include wildstar
(`**`), as it can lead to infinite recursion when you have associations that
can be traversed in a cycle.

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
`ActiveModelSerializers::Adapter::GreatExample`, or registered.

There are two ways to register an adapter:

1) The simplest, is to subclass `ActiveModelSerializers::Adapter::Base`, e.g. the below will
register the `Example::UsefulAdapter` as `"example/useful_adapter"`.

```ruby
module Example
  class UsefulAdapter < ActiveModelSerializers::Adapter::Base
  end
end
```

You'll notice that the name it registers is the underscored namespace and class.

Under the covers, when the `ActiveModelSerializers::Adapter::Base` is subclassed, it registers
the subclass as `register("example/useful_adapter", Example::UsefulAdapter)`

2) Any class can be registered as an adapter by calling `register` directly on the
`ActiveModelSerializers::Adapter` class. e.g., the below registers `MyAdapter` as
`:special_adapter`.

```ruby
class MyAdapter; end
ActiveModelSerializers::Adapter.register(:special_adapter, MyAdapter)
```

### Looking up an adapter

| Method | Return value |
| :------------ |:---------------|
| `ActiveModelSerializers::Adapter.adapter_map` | A Hash of all known adapters `{ adapter_name => adapter_class }` |
| `ActiveModelSerializers::Adapter.adapters` | A (sorted) Array of all known `adapter_names` |
| `ActiveModelSerializers::Adapter.lookup(name_or_klass)` |  The `adapter_class`, else raises an `ActiveModelSerializers::Adapter::UnknownAdapter` error |
| `ActiveModelSerializers::Adapter.adapter_class(adapter)` | Delegates to `ActiveModelSerializers::Adapter.lookup(adapter)` |
| `ActiveModelSerializers::Adapter.configured_adapter` | A convenience method for `ActiveModelSerializers::Adapter.lookup(config.adapter)` |

The registered adapter name is always a String, but may be looked up as a Symbol or String.
Helpfully, the Symbol or String is underscored, so that `get(:my_adapter)` and `get("MyAdapter")`
may both be used.

For more information, see [the Adapter class on GitHub](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/adapter.rb)

# Adapters

AMS works through two components: **serializers** and **adapters**.
Serializers describe _which_ attributes and relationships should be serialized.
Adapters describe _how_ attributes and relationships should be serialized.
You can use one of the built-in adapters (```Attributes``` is the default one) or create one by yourself, but you won't need to implement an adapter unless you wish to use a new format or media type with AMS.

## Built in Adapters

### Attributes - Default

It's the default adapter, it generates a json response without a root key.
Doesn't follow any specific convention.

### Output example

```json
[
  {
    id: 1,
    title: "My new post",
    body: "Testing my blog.",
    authors: [
      {
        id: 1,
        name: "Jon Snow",
        email: "jon@thewall.com",
        created_at: "2015-12-15T00:14:41.149Z",
        updated_at: "2015-12-15T00:14:41.149Z"
      }
    ],
    comments: [
      {
        id: 1,
        body: "Good post",
        created_at: "2015-12-15T00:15:48.643Z",
        updated_at: "2015-12-15T00:15:48.643Z",
        post_id: 1
      },
      {
      id: 2,
      body: "Winter is Coming.",
      created_at: "2015-12-15T00:16:21.578Z",
      updated_at: "2015-12-15T00:16:21.578Z",
      post_id: 1
      }
    ]
  },
  {
    id: 2,
    title: "Another post",
    body: "Just testing",
    authors: [
      {
        id: 1,
        name: "Jon Snow",
        email: "jon@thewall.com",
        created_at: "2015-12-15T00:14:41.149Z",
        updated_at: "2015-12-15T00:14:41.149Z"
      },
      {
        id: 2,
        name: "Tyrion Lannister",
        email: "theimp@lannister.com",
        created_at: "2015-12-15T00:22:56.830Z",
        updated_at: "2015-12-15T00:22:56.830Z"
      }
    ],
    comments: [
      {
        id: 3,
        body: "Just a comment",
        created_at: "2015-12-15T00:23:55.545Z",
        updated_at: "2015-12-15T00:23:55.545Z",
        post_id: 2
      }
    ]
  }
]
```

### JSON

It also generates a json response but always with a root key. The root key **can't be overridden**, and will be automatically defined accordingly to the objects being serialized.
Doesn't follow any specific convention.

### Output example

```json
{
  posts: [
    {
      id: 1,
      title: "My new post",
      body: "Testing my blog.",
      authors: [
        {
          id: 1,
          name: "Jon Snow",
          email: "jon@thewall.com",
          created_at: "2015-12-15T00:14:41.149Z",
          updated_at: "2015-12-15T00:14:41.149Z"
        }
      ],
      comments: [
        {
        id: 1,
        body: "Good post",
        created_at: "2015-12-15T00:15:48.643Z",
        updated_at: "2015-12-15T00:15:48.643Z",
        post_id: 1
        },
        {
        id: 2,
        body: "Winter is Coming.",
        created_at: "2015-12-15T00:16:21.578Z",
        updated_at: "2015-12-15T00:16:21.578Z",
        post_id: 1
        }
      ]
    },
    {
      id: 2,
      title: "Another post",
      body: "Just testing",
      authors: [
        {
          id: 1,
          name: "Jon Snow",
          email: "jon@thewall.com",
          created_at: "2015-12-15T00:14:41.149Z",
          updated_at: "2015-12-15T00:14:41.149Z"
        },
        {
          id: 2,
          name: "Tyrion Lannister",
          email: "theimp@lannister.com",
          created_at: "2015-12-15T00:22:56.830Z",
          updated_at: "2015-12-15T00:22:56.830Z"
        }
      ],
      comments: [
        {
          id: 3,
          body: "Just a comment",
          created_at: "2015-12-15T00:23:55.545Z",
          updated_at: "2015-12-15T00:23:55.545Z",
          post_id: 2
        }
      ]
    }
  ]
}
```

### JSON API

This adapter follows **version 1.0** of the format specified in
[jsonapi.org/format](http://jsonapi.org/format). It will include the associated
resources in the `"included"` member when the resource names are included in the
`include` option.

```ruby
render @posts, include: ['authors', 'comments']
```

or

```ruby
render @posts, include: 'authors,comments'
```

The format of the `include` option can be either a String composed of a comma-separated list of [relationship paths](http://jsonapi.org/format/#fetching-includes), an Array of Symbols and Hashes, or a mix of both.

### Output example

```json
{
  data: [
    {
      id: "1",
      type: "posts",
      attributes: {
        title: "My new post",
        body: "Testing my blog."
      },
      relationships: {
        authors: {
          data: [
            {
              id: 1,
              name: "Jon Snow",
              email: "jon@thewall.com",
              created_at: "2015-12-15T00:14:41.149Z",
              updated_at: "2015-12-15T00:14:41.149Z"
            }
          ]
        },
        comments: {
          data: [
            {
              id: 1,
              body: "Good post",
              created_at: "2015-12-15T00:15:48.643Z",
              updated_at: "2015-12-15T00:15:48.643Z",
              post_id: 1
            },
            {
              id: 2,
              body: "Winter is Coming.",
              created_at: "2015-12-15T00:16:21.578Z",
              updated_at: "2015-12-15T00:16:21.578Z",
              post_id: 1
            }
          ]
        }
      }
    },
    {
      id: "2",
      type: "posts",
      attributes: {
        title: "Another post",
        body: "Just testing"
      },
      relationships: {
        authors: {
          data: [
            {
              id: 1,
              name: "Jon Snow",
              email: "jon@thewall.com",
              created_at: "2015-12-15T00:14:41.149Z",
              updated_at: "2015-12-15T00:14:41.149Z"
            },
            {
              id: 2,
              name: "Tyrion Lannister",
              email: "theimp@lannister.com",
              created_at: "2015-12-15T00:22:56.830Z",
              updated_at: "2015-12-15T00:22:56.830Z"
            }
          ]
        },
        comments: {
          data: [
            {
              id: 3,
              body: "Just a comment",
              created_at: "2015-12-15T00:23:55.545Z",
              updated_at: "2015-12-15T00:23:55.545Z",
              post_id: 2
            }
          ]
        }
      }
    }
  ]
}
```

## Choosing an adapter

If you want to use a specify a default adapter, such as JsonApi, you can change this in an initializer:

```ruby
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
```

or

```ruby
ActiveModel::Serializer.config.adapter = :json_api
```

If you want to have a root key for each resource in your responses, you should use the Json or
JsonApi adapters instead of the default Attributes:

```ruby
ActiveModel::Serializer.config.adapter = :json
```

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

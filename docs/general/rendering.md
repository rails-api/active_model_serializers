[Back to Guides](../README.md)

# Rendering

### Implicit Serializer

In your controllers, when you use `render :json`, Rails will now first search
for a serializer for the object and use it if available.

```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    render json: @post
  end
end
```

In this case, Rails will look for a serializer named `PostSerializer`, and if
it exists, use it to serialize the `Post`.

### Explicit Serializer

If you wish to use a serializer other than the default, you can explicitly pass it to the renderer.

#### 1. For a resource:

```ruby
  render json: @post, serializer: PostPreviewSerializer
```

#### 2. For a resource collection:

Specify the serializer for each resource with `each_serializer`

```ruby
render json: @posts, each_serializer: PostPreviewSerializer
```

The default serializer for collections is `CollectionSerializer`.

Specify the collection serializer with the `serializer` option.

```ruby
render json: @posts, serializer: CollectionSerializer, each_serializer: PostPreviewSerializer
```

## Serializing non-ActiveRecord objects

All serializable resources must pass the
[ActiveModel::Serializer::Lint::Tests](../../lib/active_model/serializer/lint.rb#L17).

See the ActiveModelSerializers::Model for a base class that implements the full
API for a plain-old Ruby object (PORO).

## SerializableResource options

The `options` hash passed to `render` or `ActiveModel::SerializableResource.new(resource, options)`
are partitioned into `serializer_opts` and `adapter_opts`. `adapter_opts` are passed to new Adapters;
`serializer_opts` are passed to new Serializers.

The `adapter_opts` are specified in [ActiveModel::SerializableResource::ADAPTER_OPTIONS](../../lib/active_model/serializable_resource.rb#L4).
The `serializer_opts` are the remaining options.

(In Rails, the `options` are also passed to the `as_json(options)` or `to_json(options)`
methods on the resource serialization by the Rails JSON renderer.  They are, therefore, important
to know about, but not part of ActiveModelSerializers.)

See [ARCHITECTURE](../ARCHITECTURE.md) for more information.

### adapter_opts

#### fields

PR please :)

#### adapter

PR please :)

#### key_transform

```render json: posts, each_serializer: PostSerializer, key_transform: :camel_lower```

See [Key Transforms](key_transforms.md) for more informaiton.

#### meta

A `meta` member can be used to include non-standard meta-information. `meta` can
be utilized in several levels in a response.

##### Top-level

To set top-level `meta` in a response, specify it in the `render` call.

```ruby
render json: @post, meta: { total: 10 }
```

The key can be customized using `meta_key` option.

```ruby
render json: @post, meta: { total: 10 }, meta_key: "custom_meta"
```

`meta` will only be included in your response if you are using an Adapter that
supports `root`, e.g., `JsonApi` and `Json` adapters. The default adapter,
`Attributes` does not have `root`.


##### Resource-level

To set resource-level `meta` in a response, define meta in a serializer with one
of the following methods:

As a single, static string.

```ruby
meta stuff: 'value'
```

As a block containing a Hash.

```ruby
meta do
  {
    rating: 4,
    comments_count: object.comments.count
  }
end
```


#### links

If you wish to use Rails url helpers for link generation, e.g., `link(:resources) { resources_url }`, ensure your application sets
`Rails.application.routes.default_url_options`.

##### Top-level

JsonApi supports a [links object](http://jsonapi.org/format/#document-links) to be specified at top-level, that you can specify in the `render`:

```ruby
  links_object = {
    href: "http://example.com/api/posts",
    meta: {
      count: 10
    }
  }
  render json: @posts, links: links_object
```

That's the result:

```json
{
  "data": [
    {
      "type": "posts",
      "id": "1",
      "attributes": {
        "title": "JSON API is awesome!",
        "body": "You should be using JSON API",
        "created": "2015-05-22T14:56:29.000Z",
        "updated": "2015-05-22T14:56:28.000Z"
      }
    }
  ],
  "links": {
    "href": "http://example.com/api/posts",
    "meta": {
      "count": 10
    }
  }
}
```

This feature is specific to JsonApi, so you have to use the use the [JsonApi Adapter](adapters.md#jsonapi)


##### Resource-level

In your serializer, define each link in one of the following methods:

As a static string

```ruby
link :link_name, 'https://example.com/resource'
```

As a block to be evaluated. When using Rails, URL helpers are available.
Ensure your application sets `Rails.application.routes.default_url_options`.

```ruby
link :link_name_ do
  "https://example.com/resource/#{object.id}"
end

link(:link_name) { "https://example.com/resource/#{object.id}" }

link(:link_name) { resource_url(object) }

link(:link_name) { url_for(controller: 'controller_name', action: 'index', only_path: false) }

```

### serializer_opts

#### include

PR please :)

#### Overriding the root key

Overriding the resource root only applies when using the JSON adapter.

Normally, the resource root is derived from the class name of the resource being serialized.
e.g. `UserPostSerializer.new(UserPost.new)` will be serialized with the root `user_post` or `user_posts` according the adapter collection pluralization rules.

When using the JSON adapter in your initializer (ActiveModelSerializers.config.adapter = :json), or passing in the adapter in your render call, you can specify the root by passing it as an argument to `render`. For example:

```ruby
  render json: @user_post, root: "admin_post", adapter: :json
```

This will be rendered as:
```json
  {
    "admin_post": {
      "title": "how to do open source"
    }
  }
```
Note: the `Attributes` adapter (default) does not include a resource root. You also will not be able to create a single top-level root if you are using the :json_api adapter.

#### serializer

PR please :)

#### scope

PR please :)

#### scope_name

PR please :)

## Using a serializer without `render`

See [Usage outside of a controller](../howto/outside_controller_use.md#serializing-before-controller-render).

## Pagination

See [How to add pagination links](https://github.com/rails-api/active_model_serializers/blob/master/docs/howto/add_pagination_links.md).

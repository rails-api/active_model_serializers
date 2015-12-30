[Back to Guides](../README.md)

# Getting Started

## Creating a Serializer

The easiest way to create a new serializer is to generate a new resource, which
will generate a serializer at the same time:

```
$ rails g resource post title:string body:string
```

This will generate a serializer in `app/serializers/post_serializer.rb` for
your new model. You can also generate a serializer for an existing model with
the serializer generator:

```
$ rails g serializer post
```

The generated serializer will contain basic `attributes` and
`has_many`/`has_one`/`belongs_to` declarations, based on the model. For example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments
  has_one :author
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post_id
end
```

The attribute names are a **whitelist** of attributes to be serialized.

The `has_many`, `has_one`, and `belongs_to` declarations describe relationships between
resources. By default, when you serialize a `Post`, you will get its `Comments`
as well.

For more information, see [Serializers](/docs/general/serializers.md).

### Namespaced Models

When serializing a model inside a namespace, such as `Api::V1::Post`, ActiveModelSerializers will expect the corresponding serializer to be inside the same namespace (namely `Api::V1::PostSerializer`).

### Model Associations and Nested Serializers

When declaring a serializer for a model with associations, such as:
```ruby
class PostSerializer < ActiveModel::Serializer
  has_many :comments
end
```
ActiveModelSerializers will look for `PostSerializer::CommentSerializer` in priority, and fall back to `::CommentSerializer` in case the former does not exist. This allows for more control over the way a model gets serialized as an association of an other model.

For example, in the following situation:

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :body, :date, :nb_likes
end

class PostSerializer < ActiveModel::Serializer
  has_many :comments
  class CommentSerializer < ActiveModel::Serializer
    attributes :body_short
  end
end
```

ActiveModelSerializers will use `PostSerializer::CommentSerializer` (thus including only the `:body_short` attribute) when serializing a `Comment` as part of a `Post`, but use `::CommentSerializer` when serializing a `Comment` directly (thus including `:body, :date, :nb_likes`).

## Rails Integration

ActiveModelSerializers will automatically integrate with your Rails app,
so you won't need to update your controller.
This is a example of how the controller will look:

```ruby
class PostsController < ApplicationController

  def show
    @post = Post.find(params[:id])
    render json: @post
  end

end
```

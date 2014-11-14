# ActiveModel::Serializers

[![Build Status](https://travis-ci.org/rails-api/active_model_serializers.svg)](https://travis-ci.org/rails-api/active_model_serializers)

ActiveModel::Serializers brings convention over configuration to your JSON generation.

AMS does this through two components: **serializers** and **adapters**. Serializers describe which attributes and relationships should be serialized. Adapters describe how attributes and relationships should be serialized.

# MAINTENANCE, PLEASE READ

This is the master branch of AMS. It will become the `0.10.0` release when it's
ready, but it's not. You probably don't want to use it yet.

There are two released versions of AMS that you may want to use: `0.9.x` and
`0.8.x`. `9` was recently `master`, so if you were using master, you probably want
to use it. `8` was the version that was on RubyGems, so if you were using that,
that's probably what you want.

`0.10.x` will be based on the `0.8.0` code, but with a more flexible
architecture. We'd love your help.

For more, please see [the rails-api-core mailing list](https://groups.google.com/d/msg/rails-api-core/8zu1xjIOTAM/siZ0HySKgaAJ).

Thanks!

## Example

Given two models, a `Post(title: string, body: text)` and a
`Comment(name:string, body:text, post_id:integer)`, you will have two
serializers:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments

  url :post
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post

  url [:post, :comment]
end
```

Generally speaking, you as a user of AMS will write (or generate) these
serializer classes. By default, they will use the JsonApiAdapter, implemented
by AMS. If you want to use a different adapter, such as a HalAdapter, you can
change this in an initializer:

```ruby
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::HalAdapter
```

or

```ruby
ActiveModel::Serializer.config.adapter = :hal
```

You won't need to implement an adapter unless you wish to use a new format or
media type with AMS.

If you would like the key in the outputted JSON to be different from its name in ActiveRecord, you can use the :key option to customize it:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :body

  # look up :subject on the model, but use +title+ in the JSON
  attribute :subject, :key => :title
  has_many :comments
end
```

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

### Built in Adapters

The `:json_api` adapter will include the associated resources in the `"linked"`
member when the resource names are included in the `include` option.

```ruby
  render @posts, include: 'authors,comments'
```

### Specify a serializer

If you wish to use a serializer other than the default, you can explicitly pass it to the renderer.

#### 1. For a resource:

```ruby
  render json: @post, serializer: PostPreviewSerializer
```

#### 2. For an array resource:

```ruby
# Use the default `ArraySerializer`, which will use `each_serializer` to
# serialize each element
render json: @posts, each_serializer: PostPreviewSerializer

# Or, you can explicitly provide the collection serializer as well
render json: @posts, serializer: PaginatedSerializer, each_serializer: PostPreviewSerializer
```

## Installation

Add this line to your application's Gemfile:

```
gem 'active_model_serializers'
```

And then execute:

```
$ bundle
```

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

The generated seralizer will contain basic `attributes` and
`has_many`/`belongs_to` declarations, based on the model. For example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments

  url :post
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post_id

  url [:post, :comment]
end
```

The attribute names are a **whitelist** of attributes to be serialized.

The `has_many` and `belongs_to` declarations describe relationships between
resources. By default, when you serialize a `Post`, you will get its `Comment`s
as well.

The `url` declaration describes which named routes to use while generating URLs
for your JSON. Not every adapter will require URLs.

## Getting Help

If you find a bug, please report an [Issue](https://github.com/rails-api/active_model_serializers/issues/new).

If you have a question, please [post to Stack Overflow](http://stackoverflow.com/questions/tagged/active-model-serializers).

Thanks!

## Contributing

1. Fork it ( https://github.com/rails-api/active_model_serializers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

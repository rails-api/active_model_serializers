# ActiveModel::Serializers

[![Build Status](https://travis-ci.org/rails-api/active_model_serializers.svg)](https://travis-ci.org/rails-api/active_model_serializers)

ActiveModel::Serializers brings convention over configuration to your JSON generation.

AMS does this through two components: **serializers** and **adapters**.
Serializers describe _which_ attributes and relationships should be serialized.
Adapters describe _how_ attributes and relationships should be serialized.

By default AMS will use the **Json Adapter**. But we strongly advise you to use JsonApi Adapter that follows RC4 of the format specified in [jsonapi.org/format](http://jsonapi.org/format).
Check how to change the adapter in the sections bellow.

# RELEASE CANDIDATE, PLEASE READ

This is the master branch of AMS. It will become the `0.10.0` release when it's
ready. Currently this is a release candidate. This is **not** backward
compatible with `0.9.0` or `0.8.0`.

`0.10.x` will be based on the `0.8.0` code, but with a more flexible
architecture. We'd love your help. [Learn how you can help here.](https://github.com/rails-api/active_model_serializers/blob/master/CONTRIBUTING.md)

## Example

Given two models, a `Post(title: string, body: text)` and a
`Comment(name:string, body:text, post_id:integer)`, you will have two
serializers:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'posts', expires_in: 3.hours
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
serializer classes. If you want to use a different adapter, such as a JsonApi, you can
change this in an initializer:

```ruby
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
```

or

```ruby
ActiveModel::Serializer.config.adapter = :json_api
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

### Meta

If you want a `meta` attribute in your response, specify it in the `render`
call:

```ruby
render json: @post, meta: { total: 10 }
```

The key can be customized using `meta_key` option.

```ruby
render json: @post, meta: { total: 10 }, meta_key: "custom_meta"
```

`meta` will only be included in your response if there's a root. For instance,
it won't be included in array responses.

### Root key

If you want to define a custom root for your response, specify it in the `render`
call:

```ruby
render json: @post, root: "articles"
```

### Overriding association methods

If you want to override any association, you can use:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :body

  has_many :comments

  def comments
    object.comments.active
  end
end
```

### Overriding attribute methods

If you want to override any attribute, you can use:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :body

  has_many :comments

  def body
    object.body.downcase
  end
end
```

### Built in Adapters

#### JSONAPI

This adapter follows RC4 of the format specified in
[jsonapi.org/format](http://jsonapi.org/format). It will include the associated
resources in the `"included"` member when the resource names are included in the
`include` option.

```ruby
  render @posts, include: ['authors', 'comments']
  # or
  render @posts, include: 'authors,comments'
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
`has_many`/`has_one`/`belongs_to` declarations, based on the model. For example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments
  has_one :author

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

The `has_many`, `has_one`, and `belongs_to` declarations describe relationships between
resources. By default, when you serialize a `Post`, you will get its `Comment`s
as well.

You may also use the `:serializer` option to specify a custom serializer class, for example:

```ruby
  has_many :comments, serializer: CommentPreviewSerializer
```

The `url` declaration describes which named routes to use while generating URLs
for your JSON. Not every adapter will require URLs.

## Caching

To cache a serializer, call ```cache``` and pass its options.
The options are the same options of ```ActiveSupport::Cache::Store```, plus
a ```key``` option that will be the prefix of the object cache
on a pattern ```"#{key}/#{object.id}-#{object.updated_at}"```.

The cache support is optimized to use the cached object in multiple request. An object cached on a ```show``` request will be reused at the ```index```. If there is a relationship with another cached serializer it will also be created and reused automatically.

**[NOTE] Every object is individually cached.**

**[NOTE] The cache is automatically expired after update an object but it's not deleted.**

```ruby
cache(options = nil) # options: ```{key, expires_in, compress, force, race_condition_ttl}```
```

Take the example bellow:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'post', expires_in: 3.hours
  attributes :title, :body

  has_many :comments

  url :post
end
```

On this example every ```Post``` object will be cached with
the key ```"post/#{post.id}-#{post.updated_at}"```. You can use this key to expire it as you want,
but in this case it will be automatically expired after 3 hours.

### Fragmenting Caching

If there is some API endpoint that shouldn't be fully cached, you can still optimise it, using Fragment Cache on the attributes and relationships that you want to cache.

You can define the attribute by using ```only``` or ```except``` option on cache method.

**[NOTE] Cache serializers will be used at their relationships**

Example:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'post', expires_in: 3.hours, only: [:title]
  attributes :title, :body

  has_many :comments

  url :post
end
```

## Getting Help

If you find a bug, please report an [Issue](https://github.com/rails-api/active_model_serializers/issues/new).

If you have a question, please [post to Stack Overflow](http://stackoverflow.com/questions/tagged/active-model-serializers).

Thanks!

# Contributing

See [CONTRIBUTING.md](https://github.com/rails-api/active_model_serializers/blob/master/CONTRIBUTING.md)

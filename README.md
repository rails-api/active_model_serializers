# ActiveModel::Serializers 
 
[![Build Status](https://travis-ci.org/steveklabnik/active_model_serializers.svg?branch=master)](https://travis-ci.org/steveklabnik/active_model_serializers?branch=master) 

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
  attribute :title, :body
 
  has_many :comments

  url :post
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attribute :name, :body

  belongs_to :post

  url [:post, :comment]
end
```

Generally speaking, you as a user of AMS will write (or generate) these
serializer classes. By default, they will use the JsonApiAdapter, implemented
by AMS. If you want to use a different adapter, such as a HalAdapter, you can
change this in an initializer:

```ruby
ActiveModel::Serializer.default_adapter = ActiveModel::Serializer::Adapter::HalAdapter
```

You won't need to implement an adapter unless you wish to use a new format or
media type with AMS.

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
  attribute :title, :body

  has_many :comments

  url :post
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attribute :name, :body

  belongs_to :post_id

  url [:post, :comment]
end
```

The attribute names are a **whitelist** of attributes to be serialized. 
 
The `has_many` and `belongs_to` declarations describe relationships between
resources. By default, when you serialize a `Post`, you will
get its `Comment`s as well.

The `url` declaration describes which named routes to use while generating URLs
for your JSON. Not every adapter will require URLs.

## Getting Help

If you find a bug, please report an
[Issue](https://github.com/rails-api/active_model_serializers/issues/new).

If you have a question, please [post to Stack
Overflow](http://stackoverflow.com/questions/tagged/active-model-serializers).

Thanks!
 
## Contributing 
 
1. Fork it ( https://github.com/rails-api/active_model_serializers/fork ) 
2. Create your feature branch (`git checkout -b my-new-feature`) 
3. Commit your changes (`git commit -am 'Add some feature'`) 
4. Push to the branch (`git push origin my-new-feature`) 
5. Create a new Pull Request 

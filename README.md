# ActiveModel::Serializers 
 
[![Build Status](https://travis-ci.org/steveklabnik/active_model_serializers.svg?branch=master)](https://travis-ci.org/steveklabnik/active_model_serializers?branch=master) 

ActiveModel::Serializers brings convention over configuration to your JSON generation. 

AMS does this through two components: **serializers** and **adapters**. Serializers describe which attributes and relationships should be serialized. Adapters describe how attributes and relationships should be serialized.

## Example

Given two models, a `Post(title: string, body: text)` and a `Comment(name:string, body:text, post_id:integer)`, you will have two serializers:

```
class PostSerializer < ActiveModel::Serializer
  attribute :title, :body
  
  has_many :comments

  url :post
end
```

and

```
class CommentSerializer < ActiveModel::Serializer
  attribute :name, :body
  
  belongs_to :post_id
  
  url [:post, :comment]
end
```

Generally speaking, you as a user of AMS will write (or generate) these serializer classes. By default, they will use the JsonApiAdapter, implemented by AMS. If you want to use a different adapter, such as a HalAdapter, you can change this in an initializer:

```
ActiveModel::Serializer.default_adapter = ActiveModel::Serializer::Adapter::HalAdapter
```

You won't need to implement an adapter unless you wish to use a new format or media type with AMS.

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
 
    gem 'active_model_serializers' 
 
And then execute: 
 
    $ bundle 

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

The generated seralizer will contain basic `attributes` and `has_many`/`belongs_to` declarations, based on
the model. For example:

```
class PostSerializer < ActiveModel::Serializer
  attribute :title, :body
  
  has_many :comments

  url :post
end
```

and

```
class CommentSerializer < ActiveModel::Serializer
  attribute :name, :body
  
  belongs_to :post_id
  
  url [:post, :comment]
end
```

The attribute names are a **whitelist** of attributes to be serialized. 
 
The `has_many` and `belongs_to` declarations describe relationships between resources. By default, when you serialize a `Post`, you will
get its `Comment`s as well.

The `url` declaration describes which named routes to use while generating URLs for your JSON. Not every adapter will require URLs.
 
## Contributing 
 
1. Fork it ( https://github.com/rails-api/active_model_serializers/fork ) 
2. Create your feature branch (`git checkout -b my-new-feature`) 
3. Commit your changes (`git commit -am 'Add some feature'`) 
4. Push to the branch (`git push origin my-new-feature`) 
5. Create a new Pull Request 

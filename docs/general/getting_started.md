# Getting Started

## Installation

### ActiveModel::Serializer is already included on Rails >= 5

Add this line to your application's Gemfile:

```
gem 'active_model_serializers'
```

And then execute:

```
$ bundle
```

## Creating a Serialization

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
class PostSerialization < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments
  has_one :author

end
```

and

```ruby
class CommentSerialization < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post_id

end
```

## Rails Integration

AMS will automatically integrate with you Rails app, you won't need to update your controller, this is a example of how it will look like:

```ruby
class PostsController < ApplicationController

  def show
    @post = Post.find(params[:id])
    render json: @post
  end

end
```

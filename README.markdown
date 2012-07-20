[![Build Status](https://secure.travis-ci.org/josevalim/active_model_serializers.png)](http://travis-ci.org/josevalim/active_model_serializers)

# Purpose

The purpose of `ActiveModel::Serializers` is to provide an object to
encapsulate serialization of `ActiveModel` objects, including `ActiveRecord`
objects.

Serializers know about both a model and the `current_user`, so you can
customize serialization based upon whether a user is authorized to see the
content.

In short, **serializers replaces hash-driven development with object-oriented
development.**

# Installing Serializers

For now, the easiest way to install `ActiveModel::Serializers` is to add this
to your `Gemfile`:

```ruby
gem "active_model_serializers", :git => "git://github.com/josevalim/active_model_serializers.git"
```

Then, install it on the command line:

```
$ bundle install
```

# Creating a Serializer

The easiest way to create a new serializer is to generate a new resource, which
will generate a serializer at the same time:

```
$ rails g resource post title:string body:string 
```

This will generate a serializer in `app/serializers/post_serializer.rb` for
your new model. You can also generate a serializer for an existing model with
the `serializer generator`:

```
$ rails g serializer post
```

# ActiveModel::Serializer

All new serializers descend from ActiveModel::Serializer

# render :json

In your controllers, when you use `render :json`, Rails will now first search
for a serializer for the object and use it if available.

```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    render :json => @post
  end
end
```

In this case, Rails will look for a serializer named `PostSerializer`, and if
it exists, use it to serialize the `Post`. 

This also works with `render_with`, which uses `to_json` under the hood. Also
note that any options passed to `render :json` will be passed to your
serializer and available as `@options` inside.

## Getting the old version

If you find that your project is already relying on the old rails to_json
change `render :json` to `render :json => @your_object.to_json`.

# Attributes and Associations

Once you have a serializer, you can specify which attributes and associations
you would like to include in the serialized form.

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :comments
end
```

## Attributes

For specified attributes, the serializer will look up the attribute on the
object you passed to `render :json`. It uses
`read_attribute_for_serialization`, which `ActiveRecord` objects implement as a
regular attribute lookup.

If you would like the key in the outputted JSON to be different from its name
in ActiveRecord, you can use the `:key` option to customize it:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :body

  # look up :subject on the model, but use +title+ in the JSON
  attribute :subject, :key => :title
  has_many :comments
end
```

## Custom Attributes

If you would like customize your JSON to include things beyond the simple 
attributes of the model, you can override its `serializable_hash` method 
to return anything you need. For example:

```ruby
class Person < ActiveRecord::Base

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def serializable_hash options = nil
    hash = super(options)
    hash["full_name"] = full_name
    hash
  end
  
end
```

The attributes returned by `serializable_hash` are then available in your serializer 
as usual:

```ruby
class PersonSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name, :full_name
end
```

## Associations

For specified associations, the serializer will look up the association and
then serialize each element of the association. For instance, a `has_many
:comments` association will create a new `CommentSerializer` for each comment
and use it to serialize the comment.

By default, serializers simply look up the association on the original object.
You can customize this behavior by implementing a method with the name of the
association and returning a different Array. Often, you will do this to
customize the objects returned based on the current user.

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :comments

  # only let the user see comments he created.
  def comments
    post.comments.where(:created_by => scope)
  end
end
```

In a serializer, `scope` is the current authorization scope (usually
`current_user`), which the controller gives to the serializer when you call
`render :json`

As with attributes, you can also change the JSON key that the serializer should
use for a particular association.

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  # look up comments, but use +my_comments+ as the key in JSON
  has_many :comments, :key => :my_comments
end
```

## Embedding Associations

By default, associations will be embedded inside the serialized object. So if
you have a post, the outputted JSON will look like:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comments": [
      { "id": 1, "body": "what a dumb post" }
    ]
  }
}
```

This is convenient for simple use-cases, but for more complex clients, it is
better to supply an Array of IDs for the association. This makes your API more
flexible from a performance standpoint and avoids wasteful duplication.

To embed IDs instead of associations, simply use the `embed` class method:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :title, :body
  has_many :comments
end
```

Now, any associations will be supplied as an Array of IDs:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comments": [ 1, 2, 3 ]
  }
}
```

In addition to supplying an Array of IDs, you may want to side-load the data
alongside the main object. This makes it easier to process the entire package
of data without having to recursively scan the tree looking for embedded
information. It also ensures that associations that are shared between several
objects (like tags), are only delivered once for the entire payload.

You can specify that the data be included like this:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids, :include => true

  attributes :id, :title, :body
  has_many :comments
end
```

Assuming that the comments also `has_many :tags`, you will get a JSON like
this:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comments": [ 1, 2 ]
  },
  "comments": [
    { "id": 1, "body": "what a dumb post", "tags": [ 1, 2 ] },
    { "id": 2, "body": "i liked it", "tags": [ 1, 3 ] },
  ],
  "tags": [
    { "id": 1, "name": "short" },
    { "id": 2, "name": "whiny" },
    { "id": 3, "name": "happy" }
  ]
}
```

You can also specify a different root for the embedded objects than the key
used to reference them:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids, :include => true

  attributes :id, :title, :body
  has_many :comments, :key => :comment_ids, :root => :comment_objects
end
```

This would generate JSON that would look like this:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comment_ids": [ 1 ]
  },
  "comment_objects": [
    { "id": 1, "body": "what a dumb post" }
  ]
}
```

**NOTE**: The `embed :ids` mechanism is primary useful for clients that process
data in bulk and load it into a local store. For these clients, the ability to
easily see all of the data per type, rather than having to recursively scan the
data looking for information, is extremely useful.

If you are mostly working with the data in simple scenarios and manually making
Ajax requests, you probably just want to use the default embedded behavior.

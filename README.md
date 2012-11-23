[![Build Status](https://secure.travis-ci.org/rails-api/active_model_serializers.png)](http://travis-ci.org/rails-api/active_model_serializers)

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
gem "active_model_serializers", :git => "git://github.com/rails-api/active_model_serializers.git"
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
the serializer generator:

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

This also works with `respond_with`, which uses `to_json` under the hood. Also
note that any options passed to `render :json` will be passed to your
serializer and available as `@options` inside.

To specify a custom serializer for an object, there are 2 options:

#### 1. Specify the serializer in your model:

```ruby
class Post < ActiveRecord::Base
  def active_model_serializer
    FancyPostSerializer
  end
end
```

#### 2. Specify the serializer when you render the object:

```ruby
render :json => @post, :serializer => FancyPostSerializer
```

## Arrays

In your controllers, when you use `render :json` for an array of objects, AMS will
use `ActiveModel::ArraySerializer` (included in this project) as the base serializer,
and the individual `Serializer` for the objects contained in that array.

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :body
end

class PostsController < ApplicationController
  def index
    @posts = Post.all
    render :json => @posts
  end
end
```

Given the example above, the index action will return

```json
{
  "posts":
    [
      { "title": "Post 1", "body": "Hello!" },
      { "title": "Post 2", "body": "Goodbye!" }
    ]
}
```

By default, the root element is the name of the controller. For example, `PostsController`
generates a root element "posts". To change it:

```ruby
render :json => @posts, :root => "some_posts"
```

You may disable the root element for arrays at the top level, which will result in
more concise json. To disable the root element for arrays, you have 3 options:

#### 1. Disable root globally for in `ArraySerializer`. In an initializer:

```ruby
ActiveModel::ArraySerializer.root = false
```

#### 2. Disable root per render call in your controller:

```ruby
render :json => @posts, :root => false
```

#### 3. Create a custom `ArraySerializer` and render arrays with it:

```ruby
class CustomArraySerializer < ActiveModel::ArraySerializer
  self.root = false
end

# controller:
render :json => @posts, :serializer => CustomArraySerializer
```

Disabling the root element of the array with any of the above 3 methods
will produce

```json
[
  { "title": "Post 1", "body": "Hello!" },
  { "title": "Post 2", "body": "Goodbye!" }
]
```

To specify a custom serializer for the items within an array:

```ruby
render :json => @posts, :each_serializer => FancyPostSerializer
```

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

For specified attributes, a serializer will look up the attribute on the
object you passed to `render :json`. It uses
`read_attribute_for_serialization`, which `ActiveRecord` objects implement as a
regular attribute lookup.

Before looking up the attribute on the object, a serializer will check for the
presence of a method with the name of the attribute. This allows serializers to
include properties beyond the simple attributes of the model. For example:

```ruby
class PersonSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name, :full_name

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
```

Within a serializer's methods, you can access the object being
serialized as either `object` or the name of the serialized object
(e.g. `admin_comment` for the `AdminCommentSerializer`).

You can also access the `scope` method, which provides an
authorization context to your serializer. By default, scope
is the current user of your application, but this
[can be customized](#customizing-scope).

Serializers will check for the presence of a method named
`include_[ATTRIBUTE]?` to determine whether a particular attribute should be
included in the output. This is typically used to customize output
based on `scope`. For example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :author

  def include_author?
    scope.admin?
  end
end
```

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

If you would like direct, low-level control of attribute serialization, you can
completely override the `attributes` method to return the hash you need:

```ruby
class PersonSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name

  def attributes
    hash = super
    if scope.admin?
      hash["ssn"] = object.ssn
      hash["secret"] = object.mothers_maiden_name
    end
    hash
  end
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

As with attributes, you can change the JSON key that the serializer should
use for a particular association.

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  # look up comments, but use +my_comments+ as the key in JSON
  has_many :comments, :key => :my_comments
end
```

Also, as with attributes, serializers will check for the presence
of a method named `include_[ASSOCIATION]?` to determine whether a particular association
should be included in the output. For example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :comments

  def include_comments?
    !post.comments_disabled?
  end
end
```

If you would like lower-level control of association serialization, you can
override `include_associations!` to specify which associations should be included:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_one :author
  has_many :comments

  def include_associations!
    include! :author if scope.admin?
    include! :comments unless object.comments_disabled?
  end
end
```

You may also use the `:serializer` option to specify a custom serializer class and the `:polymorphic` option to specify an association that is polymorphic (STI), e.g.:

```ruby
  has_many :comments, :serializer => CommentShortSerializer
  has_one :reviewer, :polymorphic => true
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

Alternatively, you can choose to embed only the ids or the associated objects per association:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  has_many :comments, embed: :objects
  has_many :tags, embed: :ids
end
```

The JSON will look like this:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comments": [
      { "id": 1, "body": "what a dumb post" }
    ],
    "tags": [ 1, 2, 3 ]
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

## Customizing Scope

In a serializer, `scope` is the current authorization scope which the controller
provides to the serializer when you call `render :json`. By default, this is
`current_user`, but can be customized in your controller by calling
`serialization_scope`:

```ruby
class ApplicationController < ActionController::Base
  serialization_scope :current_admin
end
```

[![Build Status](https://api.travis-ci.org/rails-api/active_model_serializers.png?branch=0-9-stable)](https://travis-ci.org/rails-api/active_model_serializers)
[![Code Climate](https://codeclimate.com/github/rails-api/active_model_serializers.png)](https://codeclimate.com/github/rails-api/active_model_serializers)

# ActiveModel::Serializers

## Purpose

`ActiveModel::Serializers` encapsulates the JSON serialization of objects.
Objects that respond to read\_attribute\_for\_serialization
(including `ActiveModel` and `ActiveRecord` objects) are supported.

Serializers know about both a model and the `current_user`, so you can
customize serialization based upon whether a user is authorized to see the
content.

In short, **serializers replace hash-driven development with object-oriented
development.**

# Installing

The easiest way to install `ActiveModel::Serializers` is to add it to your
`Gemfile`:

```ruby
gem "active_model_serializers"
```

Then, install it on the command line:

```
$ bundle install
```

#### Ruby 1.8 is no longer supported!

If you must use a ruby 1.8 version (MRI 1.8.7, REE, Rubinius 1.8, or JRuby 1.8), you need to use version 0.8.x.
Versions after 0.9.0 do not support ruby 1.8. To specify version 0.8, include this in your Gemfile:

```ruby
gem "active_model_serializers", "~> 0.8.0"
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

### Support for POROs

The PORO should include ActiveModel::SerializerSupport. That's all you need to
do to have your POROs supported.

For Rails versions before Rails 4  ActiveModel::Serializers expects objects to
implement `read_attribute_for_serialization`.

# render :json

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

This also works with `respond_with`, which uses `to_json` under the hood. Also
note that any options passed to `render :json` will be passed to your
serializer and available as `@options` inside.

To specify a custom serializer for an object, you can specify the
serializer when you render the object:

```ruby
render json: @post, serializer: FancyPostSerializer
```

### Use serialization outside of ActionController::Base

When controller does not inherit from ActionController::Base,
include Serialization module manually:

```ruby
class ApplicationController < ActionController::API
  include ActionController::Serialization
end
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
    render json: @posts
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
render json: @posts, root: "some_posts"
```

You may disable the root element for arrays at the top level, which will result in
more concise json. See the next section for ways on how to do this. Disabling the
root element of the array with any of those methods will produce

```json
[
  { "title": "Post 1", "body": "Hello!" },
  { "title": "Post 2", "body": "Goodbye!" }
]
```

To specify a custom serializer for the items within an array:

```ruby
render json: @posts, each_serializer: FancyPostSerializer
```

## Render independently

By default the setting of serializer is in controller as described above which is the
recommended way. However, there may be cases you need to render the json object elsewhere
say in a helper or a view when controller is only for main object.

Then you can render the serialized JSON independently.

```ruby
def current_user_as_json_helper
  CurrentUserSerializer.new(current_user).to_json
end
```

You can also render an array of objects using ArraySerializer.

```ruby
def users_array_as_json_helper(users)
  ActiveModel::ArraySerializer.new(users, each_serializer: UserSerializer).to_json
end
```


## Disabling the root element

You have 4 options to disable the root element, each with a slightly different scope:

#### 1. Disable root globally for all, or per class

In an initializer:

```ruby
# Disable for all serializers (except ArraySerializer)
ActiveModel::Serializer.root = false

# Disable for ArraySerializer
ActiveModel::ArraySerializer.root = false
```

#### 2. Disable root per render call in your controller

```ruby
render json: @posts, root: false
```

#### 3. Subclass the serializer, and specify using it

```ruby
class CustomArraySerializer < ActiveModel::ArraySerializer
  self.root = false
end

# controller:
render json: @posts, serializer: CustomArraySerializer
```

#### 4. Define default_serializer_options in your controller

If you define `default_serializer_options` method in your controller,
all serializers in actions of this controller and it's children will use them.
One of the options may be `root: false`

```ruby
def default_serializer_options
  {
    root: false
  }
end
```

## Changing the Key Format

You can specify that serializers use the lower-camel key format at the config, class or instance level.

```ruby

ActiveModel::Serializer.setup do |config|
  config.key_format = :lower_camel
end

class BlogLowerCamelSerializer < ActiveModel::Serializer
  format_keys :lower_camel
end

BlogSerializer.new(object, key_format: :lower_camel)
```

## Changing the default association key type

You can specify that serializers use unsuffixed names as association keys by default.

`````ruby
ActiveModel::Serializer.setup do |config|
  config.default_key_type = :name
end
````

This will build association keys like `comments` or `author` instead of `comment_ids` or `author_id`.

## Getting the old version

If you find that your project is already relying on the old rails to_json
change `render :json` to `render json: @your_object.to_json`.

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
serialized as `object`.

Since this shadows any attribute named `object`, you can include them through `object.object`. For example:

```ruby
class VersionSerializer < ActiveModel::Serializer
  attributes :version_object

  def version_object
    object.object
  end
end
```

You can also access the `scope` method, which provides an
authorization context to your serializer. By default, the context
is the current user of your application, but this
[can be customized](#customizing-scope).

Serializers provide a method named `filter`, which should return an array
used to determine what attributes and associations should be included in the output.
This is typically used to customize output based on `current_user`. For example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :author

  def filter(keys)
    if scope.admin?
      keys
    else
      keys - [:author]
    end
  end
end
```

And it's also safe to mutate keys argument by doing keys.delete(:author)
in case you want to avoid creating two extra arrays. Note that if you do an
in-place modification, you still need to return the modified array.

### Alias Attribute
If you would like the key in the outputted JSON to be different from its name
in ActiveRecord, you can declare the attribute with the different name
and redefine that method:

```ruby
class PostSerializer < ActiveModel::Serializer
  # look up subject on the model, but use title in the JSON
  def title
    object.subject
  end

  attributes :id, :body, :title
  has_many :comments
end
```

If you would like to add meta information to the outputted JSON, use the `:meta`
option:

```ruby
render json: @posts, serializer: CustomArraySerializer, meta: {total: 10}
```

The above usage of `:meta` will produce the following:

```json
{
  "meta": { "total": 10 },
  "posts": [
    { "title": "Post 1", "body": "Hello!" },
    { "title": "Post 2", "body": "Goodbye!" }
  ]
}
```

If you would like to change the meta key name you can use the `:meta_key` option:

```ruby
render json: @posts, serializer: CustomArraySerializer, meta_object: {total: 10}, meta_key: 'meta_object'
```

The above usage of `:meta_key` will produce the following:

```json
{
  "meta_object": { "total": 10 },
  "posts": [
    { "title": "Post 1", "body": "Hello!" },
    { "title": "Post 2", "body": "Goodbye!" }
  ]
}
```

When using meta information, your serializer cannot have the `{ root: false }` option, as this would lead to
invalid JSON. If you do not have a root key, the meta information will be ignored.

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
customize the objects returned based on the current user (scope).

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :comments

  # only let the user see comments he created.
  def comments
    object.comments.where(created_by: scope)
  end
end
```

As with attributes, you can change the JSON key that the serializer should
use for a particular association.

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  # look up comments, but use +my_comments+ as the key in JSON
  has_many :comments, root: :my_comments
end
```

Also, as with attributes, serializers will execute a filter method to
determine which associations should be included in the output. For
example:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :comments

  def filter(keys)
    keys.delete :comments if object.comments_disabled?
    keys
  end
end
```

Or ...

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_one :author
  has_many :comments

  def filter(keys)
    keys.delete :author unless scope.admin?
    keys.delete :comments if object.comments_disabled?
    keys
  end
end
```

You may also use the `:serializer` option to specify a custom serializer class and the `:polymorphic` option to specify an association that is polymorphic (STI), e.g.:

```ruby
  has_many :comments, serializer: CommentShortSerializer
  has_one :reviewer, polymorphic: true
```

Serializers are only concerned with multiplicity, and not ownership. `belongs_to` ActiveRecord associations can be included using `has_one` in your serializer.

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
    "comment_ids": [ 1, 2, 3 ]
  }
}
```

You may also choose to embed the IDs by the association's name underneath a
`key` for the resource. For example, say we want to change `comment_ids`
to `comments` underneath a `links` key:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  has_many :comments, embed: :ids, key: :comments, embed_namespace: :links
end
```

The JSON will look like this:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "links": {
      "comments": [ 1, 2, 3 ]
    }
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
    "tag_ids": [ 1, 2, 3 ]
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
  embed :ids, include: true

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
    "comment_ids": [ 1, 2 ]
  },
  "comments": [
    { "id": 1, "body": "what a dumb post", "tag_ids": [ 1, 2 ] },
    { "id": 2, "body": "i liked it", "tag_ids": [ 1, 3 ] },
  ],
  "tags": [
    { "id": 1, "name": "short" },
    { "id": 2, "name": "whiny" },
    { "id": 3, "name": "happy" }
  ]
}
```

If you would like to namespace association JSON underneath a certain key in
the root document (say, `linked`), you can specify an `embed_in_root_key`:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids, include: true, embed_in_root_key: :linked

  attributes: :id, :title, :body
  has_many :comments, :tags
end
```

The above would yield the following JSON document:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comment_ids": [ 1, 2 ]
  },
  "linked": {
    "comments": [
      { "id": 1, "body": "what a dumb post", "tag_ids": [ 1, 2 ] },
      { "id": 2, "body": "i liked it", "tag_ids": [ 1, 3 ] },
    ],
    "tags": [
      { "id": 1, "name": "short" },
      { "id": 2, "name": "whiny" },
      { "id": 3, "name": "happy" }
    ]
  }
}
```

When side-loading data, your serializer cannot have the `{ root: false }` option,
as this would lead to invalid JSON. If you do not have a root key, the `include`
instruction will be ignored

You can also specify a different root for the embedded objects than the key
used to reference them:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :title, :body
  has_many :comments, key: :comment_ids, root: :comment_objects
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

You can also specify a different attribute to use rather than the ID of the
objects:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :title, :body
  has_many :comments, key: :external_id
end
```

This would generate JSON that would look like this:

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "body": "A body!",
    "comment_ids": [ "COMM001" ]
  },
  "comments": [
    { "id": 1, "external_id": "COMM001", "body": "what a dumb post" }
  ]
}
```

**NOTE**: The `embed :ids` mechanism is primary useful for clients that process
data in bulk and load it into a local store. For these clients, the ability to
easily see all of the data per type, rather than having to recursively scan the
data looking for information, is extremely useful.

If you are mostly working with the data in simple scenarios and manually making
Ajax requests, you probably just want to use the default embedded behavior.


## Embedding Polymorphic Associations

Because we need both the id and the type to be able to identify a polymorphic associated model, these are serialized in a slightly different format than common ones.

When embedding entire objects:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title
  has_many :attachments, polymorphic: true
end
```

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "attachments": [
      {
        "type": "image",
        "image": {
          "id": 3,
          "name": "logo",
          "url": "http://images.com/logo.jpg"
        }
      },
      {
        "type": "video",
        "video": {
          "id": 12,
          "uid": "XCSSMDFWW",
          "source": "youtube"
        }
      }
    ]
  }
}
```

When embedding ids:

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :title
  has_many :attachments, polymorphic: true
end
```

```json
{
  "post": {
    "id": 1,
    "title": "New post",
    "attachment_ids": [
      {
        "type": "image",
        "id": 12
      },
      {
        "type": "video",
        "id": 3
      }
    ]
  }
}
```


## Customizing Scope

In a serializer, `current_user` is the current authorization scope which the controller
provides to the serializer when you call `render :json`. By default, this is
`current_user`, but can be customized in your controller by calling
`serialization_scope`:

```ruby
class ApplicationController < ActionController::Base
  serialization_scope :current_admin
end
```

The above example will also change the scope from `current_user` to
`current_admin`.

Please note that, until now, `serialization_scope` doesn't accept a second
object with options for specifying which actions should or should not take a
given scope in consideration.

To be clear, it's not possible, yet, to do something like this:

```ruby
class SomeController < ApplicationController
  serialization_scope :current_admin, except: [:index, :show]
end
```

So, in order to have a fine grained control of what each action should take in
consideration for its scope, you may use something like this:

```ruby
class CitiesController < ApplicationController
  serialization_scope nil

  def index
    @cities = City.all

    render json: @cities, each_serializer: CitySerializer
  end

  def show
    @city = City.find(params[:id])

    render json: @city, scope: current_admin
  end
end
```

Assuming that the `current_admin` method needs to make a query in the database
for the current user, the advantage of this approach is that, by setting
`serialization_scope` to `nil`, the `index` action no longer will need to make
that query, only the `show` action will.

## Testing

In order to test a Serializer, you can just call `.new` on it, passing the object to serialize:

### MiniTest

```ruby
class TestPostSerializer < Minitest::Test
  def setup
    @serializer = PostSerializer.new Post.new(id: 123, title: 'some title', body: 'some text')
  end

  def test_special_json_for_api
    assert_equal '{"post":{"id":123,"title":"some title","body":"some text"}}', @serializer.to_json
  end
```

### RSpec

```ruby
describe PostSerializer do
  it "creates special JSON for the API" do
    serializer = PostSerializer.new Post.new(id: 123, title: 'some title', body: 'some text')
    expect(serializer.to_json).to eql('{"post":{"id":123,"title":"some title","body":"some text"}}')
  end
end
```

## Caching

NOTE: This functionality was removed from AMS and it's in the TODO list.
We need to re-think and re-design the caching strategy for the next
version of AMS.

To cache a serializer, call `cached` and define a `cache_key` method:

```ruby
class PostSerializer < ActiveModel::Serializer
  cached  # enables caching for this serializer

  attributes :title, :body

  def cache_key
    [object, scope]
  end
end
```

The caching interface uses `Rails.cache` under the hood.

# ApplicationSerializer

By default, new serializers descend from ActiveModel::Serializer. However, if you wish to share behaviour across your serializers you can create an ApplicationSerializer at ```app/serializers/application_serializer.rb```:

```ruby
class ApplicationSerializer < ActiveModel::Serializer
end
```

Any newly generated serializers will automatically descend from ApplicationSerializer.

```
$ rails g serializer post
```

now generates:

```ruby
class PostSerializer < ApplicationSerializer
  attributes :id
end
````

# Design and Implementation Guidelines

## Keep it Simple

`ActiveModel::Serializers` is capable of producing complex JSON views/large object
trees, and it may be tempting to design in this way so that your client can make
fewer requests to get data and so that related querying can be optimized.
However, keeping things simple in your serializers and controllers may
significantly reduce complexity and maintenance over the long-term development
of your application. Please consider reducing the complexity of the JSON views
you provide via the serializers as you build out your application, so that
controllers/services can be more easily reused without a lot of complexity
later.

## Performance

As you develop your controllers or other code that utilizes serializers, try to
avoid n+1 queries by ensuring that data loads in an optimal fashion, e.g. if you
are using ActiveRecord, you might want to use query includes or joins as needed
to make the data available that the serializer(s) need.

[Back to Guides](../README.md)

# Serializers

Given a serializer class:

```ruby
class SomeSerializer < ActiveModel::Serializer
end
```

The following methods may be defined in it:

### Attributes

#### ::attributes

Serialization of the resource `title` and `body`

| In Serializer               | #attributes |
|---------------------------- |-------------|
| `attributes :title, :body`  | `{ title: 'Some Title', body: 'Some Body' }`
| `attributes :title, :body`<br>`def body "Special #{object.body}" end` | `{ title: 'Some Title', body: 'Special Some Body' }`


#### ::attribute

Serialization of the resource `title`

| In Serializer               | #attributes |
|---------------------------- |-------------|
| `attribute :title`          | `{ title: 'Some Title' } `
| `attribute :title, key: :name` | `{ name: 'Some Title' } `
| `attribute :title { 'A Different Title'}` | `{ title: 'A Different Title' } `
| `attribute :title`<br>`def title 'A Different Title' end` | `{ title: 'A Different Title' }`

[PR please for conditional attributes:)](https://github.com/rails-api/active_model_serializers/pull/1403)

### Associations

#### ::has_one

e.g.

```ruby
has_one :bio
has_one :blog, key: :site
has_one :maker, virtual_value: { id: 1 }
```

#### ::has_many

e.g.

```ruby
has_many :comments
has_many :comments, key: :reviews
has_many :comments, serializer: CommentPreviewSerializer
has_many :reviews, virtual_value: [{ id: 1 }, { id: 2 }]
has_many :comments, key: :last_comments do
  last(1)
end
```

#### ::belongs_to

e.g.

```ruby
belongs_to :author, serializer: AuthorPreviewSerializer
belongs_to :author, key: :writer
belongs_to :post
belongs_to :blog
def blog
  Blog.new(id: 999, name: 'Custom blog')
end
```

### Caching

#### ::cache

e.g.

```ruby
cache key: 'post', expires_in: 0.1, skip_digest: true
cache expires_in: 1.day, skip_digest: true
cache key: 'writer', skip_digest: true
cache only: [:name], skip_digest: true
cache except: [:content], skip_digest: true
cache key: 'blog'
cache only: [:id]
```

#### #cache_key

e.g.

```ruby
# Uses a custom non-time-based cache key
def cache_key
  "#{self.class.name.downcase}/#{self.id}"
end
```

### Other

#### ::type

e.g.

```ruby
class UserProfileSerializer < ActiveModel::Serializer
  type 'profile'
end
```

#### ::link

e.g.

```ruby
link :other, 'https://example.com/resource'
link :self do
 href "https://example.com/link_author/#{object.id}"
end
```

#### #object

The object being serialized.

#### #root

PR please :)

#### #scope

PR please :)

#### #read_attribute_for_serialization(key)

The serialized value for a given key. e.g. `read_attribute_for_serialization(:title) #=> 'Hello World'`

#### #links

PR please :)

#### #json_key

PR please :)

## Examples

Given two models, a `Post(title: string, body: text)` and a
`Comment(name: string, body: text, post_id: integer)`, you will have two
serializers:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'posts', expires_in: 3.hours
  attributes :title, :body

  has_many :comments
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post
end
```

Generally speaking, you, as a user of ActiveModelSerializers, will write (or generate) these
serializer classes.

## More Info

For more information, see [the Serializer class on GitHub](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model/serializer.rb)

## Overriding association methods

To override an association, call `has_many`, `has_one` or `belongs_to` with a block:

```ruby
class PostSerializer < ActiveModel::Serializer
  has_many :comments do
    object.comments.active
  end
end
```

## Overriding attribute methods

To override an attribute, call `attribute` with a block:

```ruby
class PostSerializer < ActiveModel::Serializer
  attribute :body do
    object.body.downcase
  end
end
```

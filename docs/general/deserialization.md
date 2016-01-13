[Back to Guides](../README.md)

# Deserialization

This is currently an *experimental* feature. The interface may change.

## JSON API

The `ActiveModelSerializers::Deserialization` defines two methods (namely `jsonapi_parse` and `jsonapi_parse!`), which take a `Hash` or an instance of `ActionController::Parameters` representing a JSON API payload, and return a hash that can directly be used to create/update models. The bang version throws an `InvalidDocument` exception when parsing fails, whereas the "safe" version simply returns an empty hash.

- Parameters
  - document: `Hash` or `ActionController::Parameters` instance
  - options:
    - only: `Array` of whitelisted fields
    - except: `Array` of blacklisted fields
    - keys: `Hash` of fields the name of which needs to be modified (e.g. `{ :author => :user, :date => :created_at }`)

Example:

```ruby
class PostsController < ActionController::Base
  def create
    Post.create(create_params)
  end

  def create_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:title, :content, :author])
  end
end
```

## Attributes/Json

There is currently no deserialization for those adapters.

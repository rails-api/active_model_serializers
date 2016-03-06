[Back to Guides](../README.md)

# How to add pagination links

## JSON API adapter

When using the `JsonApi` adapter, pagination links will be automatically included if you use [Kaminari](https://github.com/amatsuda/kaminari)
or [WillPaginate](https://github.com/mislav/will_paginate) within a Rails controller:

* Using Kaminari:

```ruby
class PostsController < ApplicationController
  def index
    posts = Post.page(params[:page]).per(params[:per_page])
    render json: posts
  end
end
```

* Using WillPaginate:

```ruby
class PostsController < ApplicationController
  def index
    posts = Post.page(params[:page]).per_page(params[:per_page])
    render json: posts
  end
end
```

The response might look like:
```json
{
  "data": [
    {
      "type": "articles",
      "id": "3",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
        "body": "The shortest article. Ever.",
        "created": "2015-05-22T14:56:29.000Z",
        "updated": "2015-05-22T14:56:28.000Z"
      }
    }
  ],
  "links": {
    "self": "http://example.com/articles?page[number]=3&page[size]=1",
    "first": "http://example.com/articles?page[number]=1&page[size]=1",
    "prev": "http://example.com/articles?page[number]=2&page[size]=1",
    "next": "http://example.com/articles?page[number]=4&page[size]=1",
    "last": "http://example.com/articles?page[number]=13&page[size]=1"
  }
}
```

ActiveModelSerializers pagination relies on paginated collections which define the methods `#current_page`, `#total_pages`, and `#size`.
Such methods are supported by both [Kaminari](https://github.com/amatsuda/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate),
but you can also roll out your own paginated collection by defining these methods.

If you do not want pagination links to be automatically rendered, you may disable it by setting the `ActiveModelSerializers.config.collection_serializer` config to
`ActiveModel::Serializer::NonPaginatedCollectionSerializer`.

If you want to disable pagination links for a specific controller, you may set the `serializer` option to `ActiveModel::Serializer::NonPaginatedCollectionSerializer`:

``` ruby
class PostsController < ApplicationController
  def index
    posts = Post.page(params[:page]).per_page(params[:per_page])
    render json: posts, serializer: ActiveModel::Serializer::NonPaginatedCollectionSerializer
  end
end
```

### Json adapter

If you are using the `Json` adapter, pagination links will not be included automatically, but it is possible to handle pagination using the `meta` option:

```ruby
class PostsController < ApplicationController
  def index
    posts = Post.page(params[:page]).per_page(params[:per_page])
    render json: posts, meta: pagination_dict(posts)
  end

  private

  def pagination_dict(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end
end
```

The response might look like:
```json
{
  "posts": [
    {
      "id": 2,
      "title": "JSON API paints my bikeshed!",
      "body": "The shortest article. Ever."
    }
  ],
  "meta": {
    "current_page": 3,
    "next_page": 4,
    "prev_page": 2,
    "total_pages": 10,
    "total_count": 10
  }
}
```

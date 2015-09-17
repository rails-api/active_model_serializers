# How to add pagination links

### JSON-API adapter

Pagination links will be included in your response automatically as long as the resource is paginated and if you are using a ```JSON-API``` adapter.

If you want pagination links in your response, use [Kaminari](https://github.com/amatsuda/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate).

###### Kaminari examples
```ruby
#array
@posts = Kaminari.paginate_array([1, 2, 3]).page(3).per(1)
render json: @posts

#active_record
@posts = Post.page(3).per(1)
render json: @posts
```

###### WillPaginate examples

```ruby
#array
@posts = [1,2,3].paginate(page: 3, per_page: 1)
render json: @posts

#active_record
@posts = Post.page(3).per_page(1)
render json: @posts
```

```ruby
ActiveModel::Serializer.config.adapter = :json_api
```

ex:
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

AMS pagination relies on a paginated collection with the methods `current_page`, `total_pages`, and `size`, such as are supported by both [Kaminari](https://github.com/amatsuda/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate).


### JSON adapter

If you are using `JSON` adapter, pagination links will not be included automatically, but it is possible to do so using `meta` key.

In your action specify a custom serializer.
```ruby
render json: @posts, serializer: PaginatedSerialization, each_serializer: PostPreviewSerialization
```

And then, you could do something like the following class.
```ruby
class PaginatedSerialization < ActiveModel::Serializer::ArraySerializer
  def initialize(object, options={})
    meta_key = options[:meta_key] || :meta
    options[meta_key] ||= {}
    options[meta_key] = {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
    super(object, options)
  end
end
```
ex.
```json
{
  "articles": [
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

### FlattenJSON adapter

This adapter does not allow us to use `meta` key, due to that it is not possible to add pagination links.

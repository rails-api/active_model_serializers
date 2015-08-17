# How to add pagination links

Pagination links will be included in your response automatically as long as the resource is paginated and if you are using a ```JSON-API``` adapter. The others adapters does not have this feature.

If you want pagination links in your response, use [Kaminari](https://github.com/amatsuda/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate).

```ruby
#kaminari example
@posts = Kaminari.paginate_array(Post.all).page(3).per(1)
render json: @posts

#will_paginate example
@posts = Post.all.paginate(page: 3, per_page: 1)
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

AMS relies on either [Kaminari](https://github.com/amatsuda/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate). Please install either dependency by adding one of those to your Gemfile.

# How to add pagination links

If you want pagination links in your response, specify it in the `render`

```ruby
  render json: @posts, pagination: true
```

AMS relies on either `Kaminari` or `WillPaginate`. Please install either dependency by adding one of those to your Gemfile.

Pagination links will only be included in your response if you are using a ```JSON-API``` adapter, the others adapters doesn't have this feature.

```ruby
ActiveModel::Serializer.config.adapter = :json_api
```

ex:
```json
{
  "data": [
    {
      "type": "articles",
      "id": "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
        "body": "The shortest article. Ever.",
        "created": "2015-05-22T14:56:29.000Z",
        "updated": "2015-05-22T14:56:28.000Z"
      }
    }
  ],
  "links": {
    "first": "?page=1&per_page=1",
    "prev": "?page=2&per_page=1",
    "next": "?page=4&per_page=1",
    "last": "?page=13&per_page=1"
  }
}
```

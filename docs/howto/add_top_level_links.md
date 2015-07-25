# How to add top-level links

JsonApi supports a [links object](http://jsonapi.org/format/#document-links) to be specified at top-level, that you can specify in the `render`:

```ruby
  render json: @posts, links: { "self": "http://example.com/api/posts" }
```

That's the result:

```json
{
  "data": [
    {
      "type": "posts",
      "id": "1",
      "attributes": {
        "title": "JSON API is awesome!",
        "body": "You should be using JSON API",
        "created": "2015-05-22T14:56:29.000Z",
        "updated": "2015-05-22T14:56:28.000Z"
      }
    }
  ],
  "links": {
    "self": "http://example.com/api/posts"
  }
}
```

This feature is specific to JsonApi, so you have to use the use the [JsonApi Adapter](https://github.com/rails-api/active_model_serializers/blob/master/docs/general/adapters.md#jsonapi)

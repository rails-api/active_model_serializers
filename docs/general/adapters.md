# Adapters

AMS does this through two components: **serializers** and **adapters**.
Serializers describe _which_ attributes and relationships should be serialized.
Adapters describe _how_ attributes and relationships should be serialized.
You can use one of the built-in adapters (```FlattenJSON``` is the default one) or create one by your one but you won't need to implement an adapter unless you wish to use a new format or
media type with AMS.

## Built in Adapters

### FlattenJSON - Default

It's the default adapter, it generates a json response without a root key.
Doesn't follow any specifc convention.

### JSON

It also generates a json response but always with a root key. The root key **can't be overridden**, and will be automatically defined accordingly with the objects being serialized.
Doesn't follow any specifc convention.

### JSONAPI

This adapter follows 1.0 of the format specified in
[jsonapi.org/format](http://jsonapi.org/format). It will include the associated
resources in the `"included"` member when the resource names are included in the
`include` option.

```ruby
  render @posts, include: ['authors', 'comments']
  # or
  render @posts, include: 'authors,comments'
```

## Choose an Adapter

If you want to use a different adapter, such as a JsonApi, you can change this in an initializer:

```ruby
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
```

or

```ruby
ActiveModel::Serializer.config.adapter = :json_api
```

If you want to have a root key on your responses you should use the Json adapter, instead of the default FlattenJson:

```ruby
ActiveModel::Serializer.config.adapter = :json
```

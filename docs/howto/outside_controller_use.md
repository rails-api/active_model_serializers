## Using AMS Outside Of A Controller

### Serializing a resource 

In AMS versions 0.10 or later, serializing resources outside of the controller context is fairly simple:

```ruby
# Create our resource
post = Post.create(title: "Sample post", body: "I love Active Model Serializers!")

# Optional options parameters
options = {}

# Create a serializable resource instance
serializable_resource = ActiveModel::SerializableResource.new(post, options)

# Convert your resource into json
model_json = serializable_resource.as_json
``` 

### Retrieving a Resource's Active Model Serializer

If you want to retrieve a serializer for a specific resource, you can do the following:

```ruby
# Create our resource 
post = Post.create(title: "Another Example", body: "So much fun.")

# Optional options parameters
options = {}

# Retrieve the default serializer for posts
serializer = ActiveModel::Serializer.serializer_for(post, options)
```

You could also retrieve the serializer via: 

```ruby
ActiveModel::SerializableResource.new(post, options).serializer 
```

Both approaches will return an instance, if any, of the resource's serializer.
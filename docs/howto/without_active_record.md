# How to use ActiveModelSerializers without ActiveRecord

Every model that is to be serialized must implement the following methods

 method name | description
 ----------- | -----------
 `read_attribute_for_serialization` | a simple accessor for each attribute
 `cache_key` | the key to use for cached serializations
 `id` | id of the model
 `self.model_name` | the name of your model


## Defining Models With ActiveModel

Here is an example base model that could be used to extend all your models with when utilizing active model.

```ruby
require 'active_model'

class BaseModel
  # provides self.model_name
  include ActiveModel::Model

  attr_accessor :id, :updated_at

  def cache_key
    "#{self.class.name.downcase}/#{self.id}-#{self.updated_at.strftime("%Y%m%d%H%M%S%9N")}"
  end

  def read_attribute_for_serialization(name)
    send(name)
  end
end
```

## Defining Models Without ActiveModel

Here is an example base model that could be used to extend all your models with

```ruby
class BaseModel

  attr_accessor :id, :updated_at

  def self.model_name
    @model_name ||= self.name
  end

  def cache_key
    "#{self.class.name.downcase}/#{self.id}-#{self.updated_at.strftime("%Y%m%d%H%M%S%9N")}"
  end

  def read_attribute_for_serialization(name)
    send(name)
  end
end
```

## Serializing

One of your models may look something like the following:

```ruby
class Post < BaseModel
  attr_accessor :name, :author_name
end
```

The required files and serializer could be written as:
```ruby
require 'active_model_serializers'

class PostSerializer < ActiveModel::Serializer
  attributes :id, :name, :author

  def author
    object.author_name
  end
end
```

To serialize an instance of `Post` you'll need to do the following:

```ruby
post = Post.new
post.id = 1
post.name = 'PORO AMS'
post.author_name = 'NVP'
resource = ActiveModel::SerializableResource.new(post, adapter: :json)
resource.serializable_hash # => {:post=>{:id=>nil, :name=>nil, :author=>"NVP"}}
```

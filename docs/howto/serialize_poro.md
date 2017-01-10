[Back to Guides](../README.md)

# How to serialize a Plain-Old Ruby Object (PORO)

### Using Duck Typing
When you are first getting started with ActiveModelSerializers, it may seem only `ActiveRecord::Base` objects can be serializable, but pretty much any object can be serializable with ActiveModelSerializers.
Here is an example of a PORO that is serializable just by implementing the needed methods:

```ruby
# my_model.rb
class MyModel
  alias :read_attribute_for_serialization :send
  attr_accessor :id, :name, :level

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @level = attributes[:level]
  end

  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self)
  end
end
```

### Inheriting ActiveModelSerializers::Model
Fortunately, ActiveModelSerializers provides a [`ActiveModelSerializers::Model`](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/model.rb) which you can use in production code that will make your PORO a lot cleaner.
The above code now becomes:
```ruby
# my_model.rb
class MyModel < ActiveModelSerializers::Model
  attributes :id, :name, :level
end
```

The default serializer would be `MyModelSerializer`.

### Serializing an instance
Sometimes you don't want to create yet another class just to serialize an object.
Well, athough it is recommended to have defined classes for what you serialize,
this is possible as well:

Given the following serializer:

```ruby
class Api::V1::UserSerializer
  type :user #this is necessery, otherwise AMS will show your instance class name

  attributes :id, :name
```

```ruby
class Api::V1::UsersController
  def show
    #this is just an example
    an_instance = OpenStruct.new(id: 1, name: 'Just an example')

    an_instance.singleton_class.send(:alias_method, :read_attribute_for_serialization, :send)

    render jsonapi: an_instance, serializer: Api::V1::UserSerializer
  end
end
```

If your object is just a hash you can do the following trick:
```ruby
class Api::V1::UsersController
  def show
    #this is just an example
    an_instance = {id: 1, name: 'Just an example'}
    an_instance.singleton_class.send(:alias_method, :read_attribute_for_serialization, :[])

    render jsonapi: an_instance, serializer: Api::V1::UserSerializer,
  end
end
```
Note however that if your hash keys are strings then you will need to convert them
to symbols first (or just wrap it in `HashWithIndifferentAccess`).

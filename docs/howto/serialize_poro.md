[Back to Guides](../README.md)

# How to serialize a Plain-Old Ruby Object (PORO)

When you are first getting started with ActiveModelSerializers, it may seem only `ActiveRecord::Base` objects can be serializable, but pretty much any object can be serializable with ActiveModelSerializers.  Here is an example of a PORO that is serializable:
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

Fortunately, ActiveModelSerializers provides a [`ActiveModelSerializers::Model`](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/model.rb) which you can use in production code that will make your PORO a lot cleaner.  The above code now becomes:
```ruby
# my_model.rb
class MyModel < ActiveModelSerializers::Model
  attr_accessor :id, :name, :level
end
```

The default serializer would be `MyModelSerializer`.
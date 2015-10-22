# How to upgrade from previous versions

### Creating a Base and Collection Adapter

You can upgrade to ams ``.10`` by creating a Base and Collection Adapter to
emulate the response that your application currently serves.

###### Base Adapter

A base adapter takes a ``ActiveModel::Serializer`` instance, and creates a hash
used for serialization in its ``serializable_hash`` method. A base adapter
could look like this:

```ruby
class MyApp::BaseAdapter < ActiveModel::Serializer::Adapter::Base
  def serializable_hash(_options=nil)
    {}.tap do |hash|
      hash[:data] = serializer.attributes.merge(type: type)
    end
  end

  private

  # serializer is the passed in serializer defined in the Base class.
  def type
    serializer.object.class.name.demodulize.underscore
  end
end
```

Now in your controller, you can use the adapter in the call to ``render``,
e.g.

```ruby
class PostController < ActionController::Base
  def show
    render Post.find(params[:id]), adapter: MyApp::BaseAdapter
  end
end
```

When testing for the JSON output in a request or controller spec, you can use
the following in your tests:

```ruby
let(:json) do
  MyApp::BaseAdapter.new(described_class.new(model)).to_json
end

it 'returns the expected json' do
  get :show, format: :json
  expect(response.body).to eq json
end
```

###### Collection Adapter

A collection adapter takes a ``ActiveModel::Serializer::ArraySerializer``
instance, and like the Base Adapter creates a hash used for serialization in its
``serializeable_hash`` method. A collection adapter could look like this:

```ruby
class MyApp::CollectionAdapter < ActiveModel::Serializer::Adapter::Json
  def serializable_hash(_options=nil)
    {}.tap do |hash|
      hash[:data] = serializer_array.map do |serializer|
        serializer.attributes
      end
    end
  end

  private

  def serializer_array
    @_array ||= serializer.send(:serializers)
  end
end
```
Again, in your controller, you can use the adapter in the call to ``render``,
e.g.

```ruby
class PostController < ActionController::Base
  def index
    render Post.all, adapter: MyApp::CollectionAdapter
  end
end
```

When testing for the JSON output in a request or controller spec, you can use
the following in your tests:

```ruby
let(:json) do
  MyApp::CollectionAdapter.new(
    ActiveModel::Serializer::ArraySerializer.new(
      post
    )
  ).to_json
end
```

> After you upgrade to AMS ``.10``, you can now use the recommended JSON API
> serialization for new endpoints, and if you choose, convert existing
> endpoints to the new standard one by one.

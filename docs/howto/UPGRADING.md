# How to upgrade from previous versions

### Creating a Base and Collection Adapter

You can upgrade to ams ``.10`` by creating a custom Base Adapter to
emulate the response that your application currently serves.

###### Base Adapter

A base adapter takes a ``ActiveModel::Serializer`` or
``ActiveModel::Serializer::ArraySerializer`` instance, and creates a hash
used for serialization in its ``serializable_hash`` method. A base adapter
could look like this:

```ruby
class MyApp::BaseAdapter < ActiveModel::Serializer::Adapter::Base
  def serializable_hash(options=nil)
    options ||= {}

    if serializer.respond_to?(:each)
      serializable_hash_for_collection(options)
    else
      serializable_hash_for_single_resource(options)
    end
  end

  def serializable_hash_for_collection(options)
    serializer.map do |s|
      MyApp::BaseAdapter.new(s, instance_options).serializable_hash(options)
    end
  end

  def serializable_hash_for_single_resource(options)
    hash[:data] = serializer.attributes.merge(type: type)
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
  def index
    render Post.all, adapter: MyApp::BaseAdapter
  end

  def show
    render Post.find(params[:id]), adapter: MyApp::BaseAdapter
  end
end
```

When testing for the JSON output in a request or controller spec, you can use
something like the following in your tests:

```ruby
let(:post) { Post.create! }
let(:get_json) do
  MyApp::BaseAdapter.new(PostSerializer.new(post)).to_json
end

let(:index_json) do
  MyApp::CollectionAdapter.new(
    ActiveModel::Serializer::ArraySerializer.new(
      [post]
    )
  ).to_json
end

RSpec.describe PostController do
  it 'returns the expected json for index' do
    get :index, format: :json
    expect(response.body).to eq index_json
  end

  it 'returns the expected json for show' do
    get :show, id: post.id, format: :json
    expect(response.body).to eq get_json
  end
end
```

> After you upgrade to AMS ``.10``, you can now use the recommended JSON API
> serialization for new endpoints, and if you choose, convert existing
> endpoints to the new standard one by one.

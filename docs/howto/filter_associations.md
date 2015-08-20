## Filtering Associations

Say you have the following model: 

```
class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :products
end
```

For smaller apps, the rendering and loading of the serialized object (and its children) would be just fine. However, as your app scales, you might find yourself wanting the option of excluding associations in certain cases. 

You can do this by adding:

```
def filter(keys)
  keys.delete :products if serialization_options[:products_disabled]
end
```

There are a few ways that you can invoke this.

Rails Console / Testing: 

```
@category = Category.create(name: "Sample Category")

serializer = CategorySerializer.new(@category)
serializer.as_json(products_disabled: true)
```

Controller: 

```
class CategoryController < ApplicationController
  def index
    @categories = Category.all
    render json: @category, products_disabled: true
  end
end
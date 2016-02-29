## Passing Arbitrary Options to A Serializer

Let's say you have a basic Post Controller:

```ruby
class PostController < ApplicationController
  def dashboard  
    render json: @posts
  end
end
```

Odds are, your serializer will look something like this:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
end
```

This works all fine and well, but maybe you passing in some "artibrary" options
into the serializer. Here's what you would do:

### posts_controller.rb

```ruby
...
  def dashboard  
    render json: @posts, user_id: 12
  end
...
```

### posts_serializer.rb

```ruby
...
  def comments_by_me  
    Comments.where(user_id: instance_options[:user_id], post_id: object.id)
  end
...
```

These options can be anything that isn't already reserved for use by AMS. For example,
you won't be able to pass in a `meta` or `root` option like the example above. Those
parameters are reserved for specific behavior within the app.

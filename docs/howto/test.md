# How to test

## Test helpers

ActiveModelSerializers provides a `assert_serializer` method to be used on your controller tests to
assert that a specific serializer was used.

```ruby
class PostsControllerTest < ActionController::TestCase
  test "should render post serializer" do
    get :index
    assert_serializer "PostSerializer"
  end
end
```

See [ActiveModelSerializers::Test::Serializer](../../lib/active_model_serializers/test/serializer.rb)
for more examples and documentation.

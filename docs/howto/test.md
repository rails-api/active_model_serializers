# How to test

## Test helpers

ActiveModelSerializers provides a `assert_serializer` method to be used on your controller tests to
assert that a specific serializer was used.

```ruby
class PostsControllerTest < ActionController::TestCase
  test "should render post serializer" do
    get :index
    assert_serializer "PostSerializer"
    #  # return a custom error message
    #  assert_serializer "PostSerializer", "PostSerializer not rendered"
    #
    #  # assert that the instance of PostSerializer was rendered
    #  assert_serializer PostSerializer
    #
    #  # assert that the "PostSerializer" serializer was rendered
    #  assert_serializer :post_serializer
    #
    #  # assert that the rendered serializer starts with "Post"
    #  assert_serializer %r{\APost.+\Z}
    #
    #  # assert that no serializer was rendered
    #  assert_serializer nil
  end
end
```

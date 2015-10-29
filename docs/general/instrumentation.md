# Instrumentation

AMS uses the instrumentation API provided by Active Support this way we
can choose to be notified when AMS events occur inside our application.

## render.active_model_serializers

|key          | value                |
|-------------|----------------------|
|:serializer  | The serializer class |
|:adapter     | The adapter instance |

```ruby
{
  serializer: PostSerializer,
  adapter: #<ActiveModel::Serializer::Adapter::Attributes:0x007f96e81eb730>
}
```

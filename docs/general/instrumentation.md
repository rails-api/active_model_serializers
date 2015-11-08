# Instrumentation

ActiveModelSerializers uses the ActiveSupport::Notification API, which
allows for subscribing to events, such as for logging.

## Events

Name:

`render.active_model_serializers`

Payload (example):

```ruby
{
  serializer: PostSerializer,
  adapter: ActiveModel::Serializer::Adapter::Attributes
}
```

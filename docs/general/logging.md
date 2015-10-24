# Logging

If we are using AMS on Rails app the `Rails.logger` will be used.

On a non Rails enviroment by default the `ActiveSupport::TaggedLogging` will be
used.

If we need to customize the logger we can define this in an initializer:

```ruby
ActiveModel::Serializer.logger = Logger.new(STDOUT)
```

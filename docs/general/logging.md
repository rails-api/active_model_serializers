[Back to Guides](../README.md)

# Logging

If we are using ActiveModelSerializers on a Rails app by default the `Rails.logger` will be used.

On a non Rails enviroment by default the `ActiveSupport::TaggedLogging` will be
used.

You may customize the logger we by in an initializer, for example:

```ruby
ActiveModelSerializers.logger = Logger.new(STDOUT)
```

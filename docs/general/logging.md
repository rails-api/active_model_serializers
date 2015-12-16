[Back to Guides](../README.md)

# Logging

The default logger in a Rails application will be `Rails.logger`.

When there is no `Rails.logger`, the default logger is an instance of
`ActiveSupport::TaggedLogging` logging to STDOUT.

You may customize the logger in an initializer, for example:

```ruby
ActiveModelSerializers.logger = Logger.new(STDOUT)
```

As of Ruby 1.9.3, it is impossible to dynamically generate a Symbol
through interpolation without generating garbage. Theoretically, Ruby
should be able to take care of this by building up the String in C and
interning the C String.

Because of this, we avoid generating dynamic Symbols at runtime. For
example, instead of generating the instrumentation event dynamically, we
have a constant with a Hash of events:

```ruby
INSTRUMENT = {
  :serialize => :"serialize.serializer",
  :associations => :"associations.serializer"
}
```

If Ruby ever fixes this issue and avoids generating garbage with dynamic
symbols, this code can be removed.


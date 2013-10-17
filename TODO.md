TODO
====

  * Complete the CHANGELOG of version 0.9.0
  * Write the project's RDoc
  * Make the current format interchangeable
  * Tests for MongoID
  * Make Rails 4 controller generator output code that responds to JSON. This was true for Rails 3.2 but currently not with Rails 4.
  * Think more about the filter method. Should it filter by association name or by serialization keys? This is probably easier to explain with code. For example: def filter(keys); keys - [:comments]; end versus def filter(keys); keys - [:comments, :comment_ids]; end.
  * Re-implement merge_assoc which cached serialization output to improve performance for larger serialization operations. We could change the current implementation with a per-serializer output cache.
  * Implement the JSON API format
  * Add support for polymorphic associations
  * Come up with a better caching solution
  * Re-add Serializer#schema

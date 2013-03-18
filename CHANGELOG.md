# unreleased

* Add an alias for `scope` method to be the name of the context. By default
  this is `current_user`. The name is automatically set when using
  `serialization_scope` in the controller.

# VERSION 0.7



# VERSION 0.6

* Serialize sets properly
* Add root option to ArraySerializer
* Support polymorphic associations
* Support :each_serializer in ArraySerializer
* Add `scope` method to easily access the scope in the serializer
* Fix regression with Rails 3.2.6; add Rails 4 support
* Allow serialization_scope to be disabled with serialization_scope nil
* Array serializer should support pure ruby objects besides serializers

# VERSION 0.5 (May 16, 2012)

* First tagged version
* Changes generators to always generate an ApplicationSerializer

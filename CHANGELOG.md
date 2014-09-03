# VERSION 0.9.0.pre

* The following methods were removed
  - Model#active\_model\_serializer
  - Serializer#include!
  - Serializer#include?
  - Serializer#attr\_disabled=
  - Serializer#cache
  - Serializer#perform\_caching
  - Serializer#schema (needs more discussion)
  - Serializer#attribute
  - Serializer#include\_#{name}? (filter method added)
  - Serializer#attributes (took a hash)

* The following things were added
  - Serializer#filter method
  - CONFIG object

* Remove support for ruby 1.8 versions.

* Require rails >= 3.2.

* Serializers for associations are being looked up in a parent serializer's namespace first. Same with controllers' namespaces.

* Added a "prefix" option in case you want to use a different version of serializer.

* Serializers default namespace can be set in `default_serializer_options` and inherited by associations.

# VERSION 0.8.1

* Fix bug whereby a serializer using 'options' would blow up.

# VERSION 0.8.0

* Attributes can now have optional types.

* A new DefaultSerializer ensures that POROs behave the same way as ActiveModels.

* If you wish to override ActiveRecord::Base#to\_Json, you can now require
  'active\_record/serializer\_override'. We don't recommend you do this, but
  many users do, so we've left it optional.

* Fixed a bug where ActionController wouldn't always have MimeResponds.

* An optional caching feature allows you to cache JSON & hashes that AMS uses.
  Adding 'cached true' to your Serializers will turn on this cache.

* URL helpers used inside of Engines now work properly.

* Serializers now can filter attributes with `only` and `except`:

  ```
  UserSerializer.new(user, only: [:first_name, :last_name])
  UserSerializer.new(user, except: :first_name)
  ```

* Basic Mongoid support. We now include our mixins in the right place.

* On Ruby 1.8, we now generate an `id` method that properly serializes `id`
  columns. See issue #127 for more.

* Add an alias for `scope` method to be the name of the context. By default
  this is `current_user`. The name is automatically set when using
  `serialization_scope` in the controller.

* Pass through serialization options (such as `:include`) when a model
  has no serializer defined.

# VERSION 0.7.0

* ```embed_key``` option to allow embedding by attributes other than IDs
* Fix rendering nil with custom serializer
* Fix global ```self.root = false```
* Add support for specifying the serializer for an association as a String
* Able to specify keys on the attributes method
* Serializer Reloading via ActiveSupport::DescendantsTracker
* Reduce double map to once; Fixes datamapper eager loading.

# VERSION 0.6.0

* Serialize sets properly
* Add root option to ArraySerializer
* Support polymorphic associations
* Support :each_serializer in ArraySerializer
* Add `scope` method to easily access the scope in the serializer
* Fix regression with Rails 3.2.6; add Rails 4 support
* Allow serialization_scope to be disabled with serialization_scope nil
* Array serializer should support pure ruby objects besides serializers

# VERSION 0.5.0

* First tagged version
* Changes generators to always generate an ApplicationSerializer

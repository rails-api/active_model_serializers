## 0.08.x

### v0.8.3 (2014/12/10 14:45 +00:00)
- [#753](https://github.com/rails-api/active_model_serializers/pull/753) Test against Ruby 2.2 on Travis CI (@tricknotes)
- [#745](https://github.com/rails-api/active_model_serializers/pull/745) Missing a word (@jockee)

### v0.8.2 (2014/09/01 21:00 +00:00)
- [#612](https://github.com/rails-api/active_model_serializers/pull/612) Feature/adapter (@bolshakov)
  * adds adapters pattern
- [#615](https://github.com/rails-api/active_model_serializers/pull/615) Rails does not support const_defined? in development mode (@tpitale)
- [#613](https://github.com/rails-api/active_model_serializers/pull/613) README: typo fix on attributes (@spk)
- [#614](https://github.com/rails-api/active_model_serializers/pull/614) Fix rails 4.0.x build. (@arthurnn)
- [#610](https://github.com/rails-api/active_model_serializers/pull/610) ArraySerializer (@bolshakov)
- [#607](https://github.com/rails-api/active_model_serializers/pull/607) ruby syntax highlights (@zigomir)
- [#602](https://github.com/rails-api/active_model_serializers/pull/602) Add DSL for associations (@JordanFaust)

### 0.8.1 (May 6, 2013)

* Fix bug whereby a serializer using 'options' would blow up.

### 0.8.0 (May 5, 2013)

* Attributes can now have optional types.

* A new DefaultSerializer ensures that POROs behave the same way as ActiveModels.

* If you wish to override ActiveRecord::Base#to_Json, you can now require
  'active_record/serializer_override'. We don't recommend you do this, but
  many users do, so we've left it optional.

* Fixed a bug where ActionController wouldn't always have MimeResponds.

* An optinal caching feature allows you to cache JSON & hashes that AMS uses.
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

## [0.7.0 (March 6, 2013)](https://github.com/rails-api/active_model_serializers/commit/fabdc621ff97fbeca317f6301973dd4564b9e695)

* ```embed_key``` option to allow embedding by attributes other than IDs
* Fix rendering nil with custom serializer
* Fix global ```self.root = false```
* Add support for specifying the serializer for an association as a String
* Able to specify keys on the attributes method
* Serializer Reloading via ActiveSupport::DescendantsTracker
* Reduce double map to once; Fixes datamapper eager loading.

## 0.6.0 (October 22, 2012)

* Serialize sets properly
* Add root option to ArraySerializer
* Support polymorphic associations
* Support :each_serializer in ArraySerializer
* Add `scope` method to easily access the scope in the serializer
* Fix regression with Rails 3.2.6; add Rails 4 support
* Allow serialization_scope to be disabled with serialization_scope nil
* Array serializer should support pure ruby objects besides serializers

## 0.05.x

### [0.5.2 (June 5, 2012)](https://github.com/rails-api/active_model_serializers/commit/615afd125c260432d456dc8be845867cf87ea118#diff-0c5c12f311d3b54734fff06069efd2ac)

### [0.5.1 (May 23, 2012)](https://github.com/rails-api/active_model_serializers/commit/00194ec0e41831802fcbf893a34c0bb0853ebe14#diff-0c5c12f311d3b54734fff06069efd2ac)

### [0.5.0 (May 16, 2012)](https://github.com/rails-api/active_model_serializers/commit/33d4842dcd35c7167b0b33fc0abcf00fb2c92286)

* First tagged version
* Changes generators to always generate an ApplicationSerializer

## [0.1.0 (December 21, 2011)](https://github.com/rails-api/active_model_serializers/commit/1e0c9ef93b96c640381575dcd30be07ac946818b)

## First Commit as [Rails Serializers 0.0.1](https://github.com/rails-api/active_model_serializers/commit/d72b66d4c5355b0ff0a75a04895fcc4ea5b0c65e)
  (December 1, 2011).

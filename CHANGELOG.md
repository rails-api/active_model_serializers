# UNRELEASED

* ActiveModel::Serializable was created it has the shared code between
  AM::Serializer and AM::ArraySerializer. Basically enable objects to be
  serializable by implementing an options method to handle the options
  of the serialization and a serialize method that returns an object to
  be converted to json by the module. This also removes duplicate code.  
  https://github.com/rails-api/active_model_serializers/commit/6c6bc8872d3b0f040a200854fa5530a775824dbf

* ActiveModel::Serializer::Caching module was created it enables
  Serializers to be able to cache to\_json and serialize calls. This
  also helps removing duplicate code.  
  https://github.com/rails-api/active_model_serializers/commit/3e27110df78696ac48cafd1568f72216f348a188

* We got rid of the Association.refine method which generated
  subclasses.  
  https://github.com/rails-api/active_model_serializers/commit/24923722d4f215c7cfcdf553fd16582e28e3801b

* Associations doesn't know anymore about the source serializer.
  That didn't make any sense.  
  https://github.com/rails-api/active_model_serializers/commit/2252e8fe6dbf45660c6a35f35e2423792f2c3abf  
  https://github.com/rails-api/active_model_serializers/commit/87eadd09b9a988bc1d9b30d9a501ef7e3fc6bb87  
  https://github.com/rails-api/active_model_serializers/commit/79a6e13e8f7fae2eb4f48e83a9633e74beb6739e

* Passing options[:hash] is not public API of include!. That was
  removed.  
  https://github.com/rails-api/active_model_serializers/commit/5cbf9317051002a32c90c3f995b8b2f126f70d0c

* ActiveModel::Serializer::Associations::Config is now
  ActiveModel::Serializer::Association but it's an internal
  thing so shouldn't bother.
  ActiveModel::Serializer::Associations::Has\* are now
  ActiveModel::Serializer::Association::Has\* and inherit from
  ActiveModel::Serializer::Association  
  https://github.com/rails-api/active_model_serializers/commit/f5de334ddf1f3b9764d914a717311532021785d2  
  https://github.com/rails-api/active_model_serializers/commit/3dd422d99e8c57f113880da34f6abe583c4dadf9

* serialize\_ids call methods on the corresponding serializer if they
  are defined, instead of talking directly with the serialized object.
  Serializers are decorators so we shouldn't talk directly with
  serialized objects.

* Array items are not wrapped anymore in root element.

* embed and include were removed from AM::Serializer and there's a global config for them in AM::Serializers

  So code like ...

  class PostSerializer < ActiveModel::Serializer
    embed :ids, :include => true
    has_many :comments
  end

  should be changed to ...

  class PostSerializer < ActiveModel::Serializer
    has_many :comments, :embed => :ids, :include => true
  end

  or you could change the global defaults by adding ...

  config.active\_model\_serializers.embed = :ids
  config.active\_model\_serializers.include = true

  to the config/application.rb file

# VERSION 0.8.1

* Fix bug whereby a serializer using 'options' would blow up.

# VERSION 0.8.0

* Attributes can now have optional types.

* A new DefaultSerializer ensures that POROs behave the same way as ActiveModels.

* If you wish to override ActiveRecord::Base#to\_Json, you can now require
  'active\_record/serializer\_override'. We don't recommend you do this, but
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

# VERSION 0.5.0 (May 16, 2012)

* First tagged version
* Changes generators to always generate an ApplicationSerializer

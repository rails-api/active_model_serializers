## 0.09.x

### [0-9-stable](https://github.com/rails-api/active_model_serializers/compare/v0.9.4...0-9-stable)

### [v0.9.5 (2016-03-30)](https://github.com/rails-api/active_model_serializers/compare/v0.9.4...v0.9.5)

- [#1607](https://github.com/rails-api/active_model_serializers/pull/1607) Merge multiple nested associations. (@Hirtenknogger)

### [v0.9.4 (2016-01-05)](https://github.com/rails-api/active_model_serializers/compare/v0.9.3...v0.9.4)

- [#752](https://github.com/rails-api/active_model_serializers/pull/752) Tiny improvement of README 0-9-stable (@basiam)
- [#749](https://github.com/rails-api/active_model_serializers/pull/749) remove trailing whitespace (@shwoodard)
- [#717](https://github.com/rails-api/active_model_serializers/pull/717) fixed issue with rendering Hash which appears in rails 4.2.0.beta4 (@kurko, @greshny)
- [#790](https://github.com/rails-api/active_model_serializers/pull/790) pass context to ArraySerializer (@lanej)
- [#797](https://github.com/rails-api/active_model_serializers/pull/797) Fix and test for #490 (@afn)
- [#813](https://github.com/rails-api/active_model_serializers/pull/813) Allow to define custom serializer for given class (@jtomaszewski)
- [#841](https://github.com/rails-api/active_model_serializers/pull/841) Fix issue with embedding multiple associations under the same root key (@antstorm)
- [#748](https://github.com/rails-api/active_model_serializers/pull/748) Propagate serialization_options across associations (@raphaelpereira)

### [v0.9.3 (2015/01/21 20:29 +00:00)](https://github.com/rails-api/active_model_serializers/compare/v0.9.2...v0.9.3)

Features:
- [#774](https://github.com/rails-api/active_model_serializers/pull/774) Fix nested include attributes (@nhocki)
- [#771](https://github.com/rails-api/active_model_serializers/pull/771) Make linked resource type names consistent with root names (@sweatypitts)
- [#696](https://github.com/rails-api/active_model_serializers/pull/696) Explicitly set serializer for associations (@ggordon)
- [#700](https://github.com/rails-api/active_model_serializers/pull/700) sparse fieldsets (@arenoir)
- [#768](https://github.com/rails-api/active_model_serializers/pull/768) Adds support for `meta` and `meta_key` attribute (@kurko)

### [v0.9.2](https://github.com/rails-api/active_model_serializers/compare/v0.9.1...v0.9.2)

### [v0.9.1 (2014/12/04 11:54 +00:00)](https://github.com/rails-api/active_model_serializers/compare/v0.9.0...v0.9.1)

- [#707](https://github.com/rails-api/active_model_serializers/pull/707) A Friendly Note on Which AMS Version to Use (@jherdman)
- [#730](https://github.com/rails-api/active_model_serializers/pull/730) Fixes nested has_many links in JSONAPI (@kurko)
- [#718](https://github.com/rails-api/active_model_serializers/pull/718) Allow overriding the adapter with render option (@ggordon)
- [#720](https://github.com/rails-api/active_model_serializers/pull/720) Rename attribute with :key (0.8.x compatibility) (@ggordon)
- [#728](https://github.com/rails-api/active_model_serializers/pull/728) Use type as key for linked resources (@kurko)
- [#729](https://github.com/rails-api/active_model_serializers/pull/729) Use the new beta build env on Travis (@joshk)
- [#703](https://github.com/rails-api/active_model_serializers/pull/703) Support serializer and each_serializer options in renderer (@ggordon, @mieko)
- [#727](https://github.com/rails-api/active_model_serializers/pull/727) Includes links inside of linked resources (@kurko)
- [#726](https://github.com/rails-api/active_model_serializers/pull/726) Bugfix: include nested has_many associations (@kurko)
- [#722](https://github.com/rails-api/active_model_serializers/pull/722) Fix infinite recursion (@ggordon)
- [#1](https://github.com/rails-api/active_model_serializers/pull/1) Allow for the implicit use of ArraySerializer when :each_serializer is specified (@mieko)
- [#692](https://github.com/rails-api/active_model_serializers/pull/692) Include 'linked' member for json-api collections (@ggordon)
- [#714](https://github.com/rails-api/active_model_serializers/pull/714) Define as_json instead of to_json (@guilleiguaran)
- [#710](https://github.com/rails-api/active_model_serializers/pull/710) JSON-API: Don't include linked section if associations are empty (@guilleiguaran)
- [#711](https://github.com/rails-api/active_model_serializers/pull/711) Fixes rbx gems bundling on TravisCI (@kurko)
- [#709](https://github.com/rails-api/active_model_serializers/pull/709) Add type key when association name is different than object type (@guilleiguaran)
- [#708](https://github.com/rails-api/active_model_serializers/pull/708) Handle correctly null associations (@guilleiguaran)
- [#691](https://github.com/rails-api/active_model_serializers/pull/691) Fix embed option for associations (@jacob-s-son)
- [#689](https://github.com/rails-api/active_model_serializers/pull/689) Fix support for custom root in JSON-API adapter (@guilleiguaran)
- [#685](https://github.com/rails-api/active_model_serializers/pull/685) Serialize ids as strings in JSON-API adapter (@guilleiguaran)
- [#684](https://github.com/rails-api/active_model_serializers/pull/684) Refactor adapters to implement support for array serialization (@guilleiguaran)
- [#682](https://github.com/rails-api/active_model_serializers/pull/682) Include root by default in JSON-API serializers (@guilleiguaran)
- [#625](https://github.com/rails-api/active_model_serializers/pull/625) Add DSL for urls (@JordanFaust)
- [#677](https://github.com/rails-api/active_model_serializers/pull/677) Add support for embed: :ids option for in associations (@guilleiguaran)
- [#681](https://github.com/rails-api/active_model_serializers/pull/681) Check superclasses for Serializers (@quainjn)
- [#680](https://github.com/rails-api/active_model_serializers/pull/680) Add support for root keys (@NullVoxPopuli)
- [#675](https://github.com/rails-api/active_model_serializers/pull/675) Support Rails 4.2.0 (@tricknotes)
- [#667](https://github.com/rails-api/active_model_serializers/pull/667) Require only activemodel instead of full rails (@guilleiguaran)
- [#653](https://github.com/rails-api/active_model_serializers/pull/653) Add "_test" suffix to JsonApi::HasManyTest filename. (@alexgenco)
- [#631](https://github.com/rails-api/active_model_serializers/pull/631) Update build badge URL (@craiglittle)

### [v0.9.0](https://github.com/rails-api/active_model_serializers/compare/v0.9.0.alpha1...v0.9.0)

### [0.9.0.alpha1 - January 7, 2014](https://github.com/rails-api/active_model_serializers/compare/d72b66d4c...v0.9.0.alpha1)

### 0.9.0.pre

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

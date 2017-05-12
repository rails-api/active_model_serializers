## 0.09.x

### v0.9.3 (2015/01/21 20:29 +00:00)

Features:
- [#774](https://github.com/rails-api/active_model_serializers/pull/774) Fix nested include attributes (@nhocki)
- [#771](https://github.com/rails-api/active_model_serializers/pull/771) Make linked resource type names consistent with root names (@sweatypitts)
- [#696](https://github.com/rails-api/active_model_serializers/pull/696) Explicitly set serializer for associations (@ggordon)
- [#700](https://github.com/rails-api/active_model_serializers/pull/700) sparse fieldsets (@arenoir)
- [#768](https://github.com/rails-api/active_model_serializers/pull/768) Adds support for `meta` and `meta_key` attribute (@kurko)

### v0.9.1 (2014/12/04 11:54 +00:00)
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

### 0.9.0.alpha1 - January 7, 2014

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

* [Beginning of rewrite: c65d387705ec534db171712671ba7fcda4f49f68](https://github.com/rails-api/active_model_serializers/commit/c65d387705ec534db171712671ba7fcda4f49f68)

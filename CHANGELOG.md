### 0.10.0

Breaking changes:
  * Adapters now inherit Adapter::Base. 'Adapter' is now a module, no longer a class. [@bf4], #1138
    * using a class as a namespace that you also inherit from is complicated and circular at time i.e.
      buggy (see https://github.com/rails-api/active_model_serializers/pull/1177)
    * The class methods on Adapter aren't necessarily related to the instance methods, they're more
        Adapter functions
    * named `Base` because it's a Rails-ism
    * It helps to isolate and highlight what the Adapter interface actually is

Features:
  * adds adapters pattern
  * adds support for `meta` and `meta_key` [@kurko]
  * adds method to override association [@kurko]
  * adds `has_one` attribute for backwards compatibility [@ggordon]
  * adds JSON API support 1.0 [@benedikt]
  * adds fragment cache support [@joaomdmoura]
  * adds cache support to attributes and associations [@joaomdmoura]
  * uses model name to determine the type [@lsylvester]
  * remove root key option and split JSON adapter [@joaomdmoura]
  * adds FlattenJSON as default adapter [@joaomdmoura]
  * adds support for `pagination links` at top level of JsonApi adapter [@bacarini]
  * adds extended format for `include` option to JsonApi adapter [@beauby]

Fixes:

Misc:

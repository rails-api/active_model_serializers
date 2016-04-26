[Back to Guides](README.md)

This document focuses on architecture the 0.10.x version of ActiveModelSerializers. If you are interested in the architecture of the 0.8 or 0.9 versions,
please refer to the [0.8 README](https://github.com/rails-api/active_model_serializers/blob/0-8-stable/README.md) or
[0.9 README](https://github.com/rails-api/active_model_serializers/blob/0-9-stable/README.md).

The original design is also available [here](https://github.com/rails-api/active_model_serializers/blob/d72b66d4c5355b0ff0a75a04895fcc4ea5b0c65e/README.textile).

# ARCHITECTURE

An **`ActiveModel::Serializer`** wraps a [serializable resource](https://github.com/rails/rails/blob/4-2-stable/activemodel/lib/active_model/serialization.rb)
and exposes an `attributes` method, among a few others.
It allows you to specify which attributes and associations should be represented in the serializatation of the resource.
It requires an adapter to transform its attributes into a JSON document; it cannot be serialized itself.
It may be useful to think of it as a
[presenter](http://blog.steveklabnik.com/posts/2011-09-09-better-ruby-presenters).

The **`ActiveModel::ArraySerializer`** represent a collection of resources as serializers
and, if there is no serializer, primitives.

The **`ActiveModel::Adapter`** describes the structure of the JSON document generated from a
serializer. For example, the `Attributes` example represents each serializer as its
unmodified attributes.  The `JsonApi` adapter represents the serializer as a [JSON
API](http://jsonapi.org/) document.

The **`ActiveModelSerializers::SerializableResource`** acts to coordinate the serializer(s) and adapter
to an object that responds to `to_json`, and `as_json`.  It is used in the controller to
encapsulate the serialization resource when rendered. However, it can also be used on its own
to serialize a resource outside of a controller, as well.

## Primitive handling

Definitions: A primitive is usually a String or Array. There is no serializer
defined for them; they will be serialized when the resource is converted to JSON (`as_json` or
`to_json`).  (The below also applies for any object with no serializer.)

ActiveModelSerializers doesn't handle primitives passed to `render json:` at all.

However, when a primitive value is an attribute or in a collection,
it is not modified.

Internally, if no serializer can be found in the controller, the resource is not decorated by
ActiveModelSerializers.

If the collection serializer (ArraySerializer) cannot
identify a serializer for a resource in its collection, it raises [`NoSerializerError`](https://github.com/rails-api/active_model_serializers/issues/1191#issuecomment-142327128)
which is rescued in `ActiveModel::Serializer::Reflection#build_association` which sets
the association value directly:

```ruby
reflection_options[:virtual_value] = association_value.try(:as_json) || association_value
```

(which is called by the adapter as `serializer.associations(*)`.)

## How options are parsed

High-level overview:

- For a collection
  - `:serializer` specifies the collection serializer and
  - `:each_serializer` specifies the serializer for each resource in the collection.
- For a single resource, the `:serializer` option is the resource serializer.
- Options are partitioned in serializer options and adapter options.  Keys for adapter options are specified by
    [`ADAPTER_OPTION_KEYS`](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/serializable_resource.rb#L5).
    The remaining options are serializer options.

Details:

1. **ActionController::Serialization**
  1. `serializable_resource = ActiveModelSerializers::SerializableResource.new(resource, options)`
    1. `options` are partitioned into `adapter_opts` and everything else (`serializer_opts`).
      The `adapter_opts`  keys are defined in `ActiveModelSerializers::SerializableResource::ADAPTER_OPTION_KEYS`.
1. **ActiveModelSerializers::SerializableResource**
  1. `if serializable_resource.serializer?` (there is a serializer for the resource, and an adapter is used.)
    - Where `serializer?` is `use_adapter? && !!(serializer)`
      - Where `use_adapter?`: 'True when no explicit adapter given, or explicit value is truthy (non-nil);
        False when explicit adapter is falsy (nil or false)'
      - Where `serializer`:
        1. from explicit `:serializer` option, else
        2. implicitly from resource `ActiveModel::Serializer.serializer_for(resource)`
  1. A side-effect of checking `serializer` is:
     - The `:serializer` option is removed from the serializer_opts hash
     - If the `:each_serializer` option is present, it is removed from the serializer_opts hash and set as the `:serializer` option
  1. The serializer and adapter are created as
    1. `serializer_instance = serializer.new(resource, serializer_opts)`
    2. `adapter_instance = ActiveModel::Serializer::Adapter.create(serializer_instance, adapter_opts)`
1. **ActiveModel::Serializer::ArraySerializer#new**
  1. If the `serializer_instance` was a `ArraySerializer` and the `:serializer` serializer_opts
    is present, then [that serializer is passed into each resource](https://github.com/rails-api/active_model_serializers/blob/a54d237e2828fe6bab1ea5dfe6360d4ecc8214cd/lib/active_model/serializer/array_serializer.rb#L14-L16).
1. **ActiveModel::Serializer#attributes** is used by the adapter to get the attributes for
  resource as defined by the serializer.

## What does a 'serializable resource' look like?

- An `ActiveRecord::Base` object.
- Any Ruby object that passes the
  [Lint](http://www.rubydoc.info/github/rails-api/active_model_serializers/ActiveModel/Serializer/Lint/Tests)
  [code](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model/serializer/lint.rb).

ActiveModelSerializers provides a
[`ActiveModelSerializers::Model`](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/model.rb),
which is a simple serializable PORO (Plain-Old Ruby Object).

ActiveModelSerializers::Model may be used either as a template, or in production code.

```ruby
class MyModel < ActiveModelSerializers::Model
  attr_accessor :id, :name, :level
end
```

The default serializer for `MyModel` would be `MyModelSerializer` whether MyModel is an
ActiveRecord::Base object or not.

Outside of the controller the rules are **exactly** the same as for records. For example:

```ruby
render json: MyModel.new(level: 'awesome'), adapter: :json
```

would be serialized the same as

```ruby
ActiveModelSerializers::SerializableResource.new(MyModel.new(level: 'awesome'), adapter: :json).as_json
```

# ActiveModelSerializers

[![Build Status](https://travis-ci.org/rails-api/active_model_serializers.svg?branch=master)](https://travis-ci.org/rails-api/active_model_serializers)
(Windows: [![Build status](https://ci.appveyor.com/api/projects/status/x6xdjydutm54gvyt/branch/master?svg=true)](https://ci.appveyor.com/project/joaomdmoura/active-model-serializers/branch/master))
[![Code Quality](https://codeclimate.com/github/rails-api/active_model_serializers/badges/gpa.svg)](https://codeclimate.com/github/rails-api/active_model_serializers)
[![Test Coverage](https://codeclimate.com/github/rails-api/active_model_serializers/badges/coverage.svg)](https://codeclimate.com/github/rails-api/active_model_serializers/coverage)

## Documentation

- [0.10 (master) Documentation](https://github.com/rails-api/active_model_serializers/tree/master)
  - [![API Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/rails-api/active_model_serializers/v0.10.0.rc4)
  - [Guides](docs)
- [0.9 (0-9-stable) Documentation](https://github.com/rails-api/active_model_serializers/tree/0-9-stable)
- [0.8 (0-8-stable) Documentation](https://github.com/rails-api/active_model_serializers/tree/0-8-stable)

## About

ActiveModelSerializers brings convention over configuration to your JSON generation.

ActiveModelSerializers works through two components: **serializers** and **adapters**.

Serializers describe _which_ attributes and relationships should be serialized.

Adapters describe _how_ attributes and relationships should be serialized.

SerializableResource co-ordinates the resource, Adapter and Serializer to produce the
resource serialization. The serialization has the `#as_json`, `#to_json` and `#serializable_hash`
methods used by the Rails JSON Renderer. (SerializableResource actually delegates
these methods to the adapter.)

By default ActiveModelSerializers will use the **Attributes Adapter**.
But we strongly advise you to use **JsonApi Adapter**, which
follows 1.0 of the format specified in [jsonapi.org/format](http://jsonapi.org/format).
Check how to change the adapter in the sections below.

## RELEASE CANDIDATE, PLEASE READ

This is the **master** branch of ActiveModelSerializers.

It will become the `0.10.0` release when it's ready. Currently this is a release candidate.

`0.10.x` is **not** backward compatible with `0.9.x` nor `0.8.x`.

`0.10.x` will be based on the `0.8.0` code, but with a more flexible
architecture. We'd love your help. [Learn how you can help here.](CONTRIBUTING.md)

It is generally safe and recommended to use the master branch.

For more information, see the post '[The future of
AMS](https://medium.com/@joaomdmoura/the-future-of-ams-e5f9047ca7e9)'.

## Installation

Add this line to your application's Gemfile:

```
gem 'active_model_serializers'
```

And then execute:

```
$ bundle
```

## Getting Started

See [Getting Started](docs/general/getting_started.md) for the nuts and bolts.

More information is available in the [Guides](docs) and
[High-level behavior](README.md#high-level-behavior).

## Getting Help

If you find a bug, please report an [Issue](https://github.com/rails-api/active_model_serializers/issues/new)
and see our [contributing guide](CONTRIBUTING.md).

If you have a question, please [post to Stack Overflow](http://stackoverflow.com/questions/tagged/active-model-serializers).

If you'd like to chat, we have a [community slack](http://amserializers.herokuapp.com).

Thanks!

## High-level behavior

Given a [serializable model](lib/active_model/serializer/lint.rb):

```ruby
# either
class SomeResource < ActiveRecord::Base
  # columns: title, body
end
# or
class SomeResource < ActiveModelSerializers::Model
  attr_accessor :title, :body
end
```

And initialized as:

```ruby
resource = SomeResource.new(title: 'ActiveModelSerializers', body: 'Convention over configuration')
```

Given a serializer for the serializable model:

```ruby
class SomeSerializer < ActiveModel::Serializer
  attribute :title, key: :name
  attributes :body
end
```

The model can be serialized as:

```ruby
options = {}
serialization = SerializableResource.new(resource, options)
serialization.to_json
serialization.as_json
```

SerializableResource delegates to the adapter, which it builds as:

```ruby
adapter_options = {}
adapter = Adapter.create(serializer, adapter_options)
adapter.to_json
adapter.as_json
adapter.serializable_hash
```

The adapter formats the serializer's attributes and associations (a.k.a. includes):

```ruby
serializer_options = {}
serializer = SomeSerializer.new(resource, serializer_options)
serializer.attributes
serializer.associations
```
See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for more information.

# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

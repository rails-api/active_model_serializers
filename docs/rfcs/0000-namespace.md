- Start Date: (2015-10-29)
- RFC PR: (leave this empty)
- AMS Issue: (leave this empty)

# Summary

Provide a consistent API for the user of the AMS.

# Motivation

The actual public API is defined under `ActiveModelSerializers`,
`ActiveModel::Serializer` and `ActiveModel`.

At the `ActiveModel::Serializer` we have:

- `ActiveModel::Serializer.config`
- `ActiveModel::Serializer`

At the `ActiveModelSerializers` we have:

- `ActiveModelSerializers::Model`
- `ActiveModelSerializers.logger`

At `ActiveModel` we have:

- `ActiveModel::SerializableResource`

The idea here is to provide a single namespace `ActiveModel::Serializers` to the user.
Following the same idea we have on other gems like
[Devise](https://github.com/plataformatec/devise/blob/e9c82472ffe7c43a448945f77e034a0e47dde0bb/lib/devise.rb),
[Refile](https://github.com/refile/refile/blob/6b24c293d044862dafbf1bfa4606672a64903aa2/lib/refile.rb) and
[Active Job](https://github.com/rails/rails/blob/30bacc26f8f258b39e12f63fe52389a968d9c1ea/activejob/lib/active_job.rb)
for example.

# Detailed design

## Require statement and main module

We are adding a extension for the Active Model, so
[following the Rubygens recomendation](http://guides.rubygems.org/name-your-gem/)
for the gem name we need to change to this.

|Gem name                  | Require statement          | Main class or module     |
|--------------------------|----------------------------|--------------------------|
| active_model_serializers | `active_model/serializers` | ActiveModel::Serializers |

The expected gem name, in the gemspec is `active_model-serializers` but we don't
need to change this, we can change the code without the need of a new gem on Rubygems.

Active Model for example follow the same idea the gem name on gemspec is `activemodel` and to the end user is:

|Gem name                  | Require statement          | Main class or module     |
|--------------------------|----------------------------|--------------------------|
| activemodel              | `active_model`             | ActiveModel              |

As you can see we do not require `activemodel`(the gem name in gemspec) insted
we use `active_model`.

And based on the [bump of `0.10.0.pre` released by Steve Klabnik](https://github.com/rails-api/active_model_serializers/tree/86fc7d7227f3ce538fcb28c1e8c7069ce311f0e1)
if we take a look on README and gemspec always is used `ActiveModel::Serializers`.

## New classes and modules organization

Since this will be a big change we can do this on baby steps, read small PRs. A
possible approach is:

- Create the `ActiveModel::Serializers` namespace;
- Move all content under `ActiveModelSerializers` to be under
  `ActiveModel::Serializers`, the logger is on this step;
- Move all content under `ActiveModel::Serializer` to be under
  `ActiveModel::Serializers`, the adapter is on this steps;
- Move all content under `ActiveModel` to be under `ActiveModel::Serializers`,
  the `SerializableResource` is on this step;
- Now that all the code lives under `ActiveModel::Serializers` we can:
  - create a better name to the `ActiveModel::Serializers::Serializer`
    keeping in mind only to keep this in the same namespace
  - create a better name to the `ActiveModel::Serializers::Serializer::Adapter::JsonApi`
    probably remove this from the `ActiveModel::Serializers::Serializer`
    and do something like `ActiveModel::Serializers::Adapter::JsonApi`
    keeping in mind only to keep this in the same namespace
  - Change all public API that doesn't make sense, keeping in mind only to keep
    this in the same namespace
- Update the README;
- Update the docs;

The following table represents the current and the desired classes and modules
at the first moment.

| Current                                               | Desired                                          | Notes              |
|-------------------------------------------------------|--------------------------------------------------|--------------------|
|`ActiveModelSerializers` and `ActiveModel::Serializer` | `ActiveModel::Serializers`                       | The main namespace |
| `ActiveModelSerializers.logger`                       | `ActiveModel::Serializers.logger`                ||
|`ActiveModelSerializers::Model`                        | `ActiveModel::Serializers::Model`                ||
|`ActiveModel::SerializableResource`                    | `ActiveModel::Serializers::SerializableResource` ||
| `ActiveModel::Serializer`                             | `ActiveModel::Serializers::Serializer`           | I know that is probably a bad name, but In a second moment we can rename this to `Resource` [for example following this idea](https://github.com/rails-api/active_model_serializers/pull/1301/files#r42963185)|
|`ActiveModel::Serializer.config`                       | `ActiveModel::Serializers.config`                ||

# Drawbacks

This will be a breaking change, so all users serializers will be broken.
All PRs will need to rebase since the architeture will change a lot.

# Alternatives

We can keep the way it is, and keep in mind to not add another namespace as a
public API.

Or we can start moving the small ones that seems to be the
`ActiveModelSerializers` and `ActiveModel` and later we can handle the
`ActiveModel::Serializer`.

# Unresolved questions

What is the better class name to be used to the class that will be inherited at
the creation of a serializer.

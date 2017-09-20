# ActiveModelSerializers

## Status of AMS
AMS has had quite the rocky history. 3 rewrites, and possibly a 4th. Currently AMS is open to Proof of Concept Design PRs.

### Motivation for yet another re-write
 - The maintainers of AMS have cycled in and out a few times, and the code base has become unwieldy
 - 0.10.x's architecture could not handle all the feature requests in an elegant way.
 - performance of AMS is bad/slow.

##### Performance Comparison (jsonapi-rb vs AMS 0.10.6).

AMS is about 6 times slower than [jsonapi-rb](http://jsonapi-rb.org)

```
Calculating -------------------------------------
ams                        
                          5.509  (± 1.8%) i/s -     55.000  in  10.102302s
jsonapi-rb                 
                         15.872  (± 0.6%) i/s -    159.000  in  10.042557s
ams        eager           
                          6.166  (± 1.3%) i/s -     62.000  in  10.097632s
jsonapi-rb eager           
                         32.555  (± 0.8%) i/s -    327.000  in  10.079955s
                   with 95.0% confidence

Comparison:
jsonapi-rb eager           :       32.6 i/s
jsonapi-rb                 :       15.9 i/s - 2.05x  (± 0.02) slower
ams        eager           :        6.2 i/s - 5.28x  (± 0.08) slower
ams                        :        5.5 i/s - 5.90x  (± 0.12) slower
                   with 95.0% confidence

Calculating -------------------------------------
ams                        
                        12.566M memsize (   945.066k retained)
                       153.201k objects (    12.896k retained)
                        50.000  strings (    50.000  retained)
jsonapi-rb                 
                         5.670M memsize (     0.000  retained)
                        66.887k objects (     0.000  retained)
                        50.000  strings (     0.000  retained)
ams        eager           
                        11.316M memsize (   917.250k retained)
                       136.794k objects (    12.203k retained)
                        50.000  strings (    50.000  retained)
jsonapi-rb eager           
                         3.564M memsize (     0.000  retained)
                        37.653k objects (     0.000  retained)
                        50.000  strings (     0.000  retained)

Comparison:
jsonapi-rb eager           :    3564036 allocated
jsonapi-rb                 :    5670156 allocated - 1.59x more
ams        eager           :   11316060 allocated - 3.18x more
ams                        :   12565796 allocated - 3.53x more
```
Every scenario builds and renders [JSONAPI.org](jsonapi.org) documents of 301 records.

eager means eager loaded data (no db hits).
The benchmark for this can be found [here](https://github.com/rails-api/active_model_serializers/blob/43c1518cfff680781b943075ceeb6ca61a3536dd/benchmarks/serialization_libraries/benchmark.rb)




## About

ActiveModelSerializers is undergoing some renovations. See [Development Status](#status-of-ams).

## Getting Help

If you find a bug, please report an [Issue](https://github.com/rails-api/active_model_serializers/issues/new)
and see our [contributing guide](CONTRIBUTING.md).

If you have a question, please [post to Stack Overflow](http://stackoverflow.com/questions/tagged/active-model-serializers).

If you'd like to chat, we have a [community slack](http://amserializers.herokuapp.com).

Thanks!

## Documentation

If you're reading this at https://github.com/rails-api/active_model_serializers you are
reading documentation for our `master`, which is not yet released.

<table>
  <tr>  
    <td>
      <a href='https://github.com/rails-api/active_model_serializers/tree/0-10-stable'>0.10 (0-10-stable) Documentation
      </a>
    </td>
    <td>
      <a href='http://www.rubydoc.info/gems/active_model_serializers/0.10.6'>
        <img src='http://img.shields.io/badge/yard-docs-blue.svg' />
      </a>
    </td>
    <td>
      <a href='https://github.com/rails-api/active_model_serializers/tree/v0.10.6/docs'>
        Guides
      </a>
    </td>
  </tr>
  <tr>
    <td>
      <a href='https://github.com/rails-api/active_model_serializers/tree/0-9-stable'>0.9 (0-9-stable) Documentation
      </a>
    </td>
    <td>
      <a href='http://www.rubydoc.info/github/rails-api/active_model_serializers/0-9-stable'>
        <img src='http://img.shields.io/badge/yard-docs-blue.svg' />
      </a>
    </td>
  </tr>
  <tr>
    <td>
      <a href='https://github.com/rails-api/active_model_serializers/tree/0-8-stable'>0.8 (0-8-stable) Documentation
      </a>
    </td>
    <td>
      <a href='http://www.rubydoc.info/github/rails-api/active_model_serializers/0-8-stable'>
        <img src='http://img.shields.io/badge/yard-docs-blue.svg' />
      </a>
    </td>
  </tr>
</table>


## Status of AMS

### *Status*:

- ❗️ All existing PRs against master will need to be closed and re-opened against 0-10-stable, if so desired
- ❗️ Master, for the moment, won't have any released version of AMS on it.
- :eyes: See below for [alternatives](#alternatives)


### *Changes to 0.10.x maintenance*:

- The 0.10.x version has become a huge maintenance version.  We had hoped to get it in shape for a 1.0 release, but it is clear that isn't going to happen.  Almost none of the maintainers from 0.8, 0.9, or earlier 0.10 are still working on AMS. We'll continue to maintain 0.10.x on the 0-10-stable branch, but maintainers won't otherwise be actively developing on it.
  - We may choose to make a 0.11.x ( 0-11-stable) release based on 0-10-stable that just removes the deprecations.

### *What's happening to AMS*:

- There's been a lot of churn around AMS since it began back in [Rails 3.2](CHANGELOG-prehistory.md) and a lot of new libraries are around and the JSON:API spec has reached 1.0.
- If there is to be a 1.0 release of AMS, it will need to address the general needs of serialization in much the way ActiveJob can be used with different workers.
- The next major release *is* in development. We're starting simple and avoiding, at least at the outset, all the complications in AMS version, especially all the implicit behavior from guessing the serializer, to the association's serializer, to the serialization type, etc.
- The basic idea is that models to serializers are a one to many relationship.  Everything will need to be explicit.  If you want to serialize a User with a UserSerializer, you'll need to call it directly.  The serializer will essentially be for defining a basic JSON:API resource object: id, type, attributes, and relationships. The serializer will have an as_json method and can be told which fields (attributes/relationships) to serialize to JSON and will likely *not* know serialize any more than the relations id and type.  Serializing anything more about the relations would require code that called a serializer. (This is still somewhat in discussion).
- If this works out, the idea is to get something into Rails that existing libraries can use.

See [PR 2121](https://github.com/rails-api/active_model_serializers/pull/2121) where these changes were introduced for more information and any discussion.



## Alternatives

- [jsonapi-rb](http://jsonapi-rb.org/) is a [highly performant](https://gist.github.com/NullVoxPopuli/748e89ddc1732b42fdf42435d773734a) and modular JSON:API-only implementation.  There's a vibrant community around it that has produced projects such as [JSON:API Suite](https://jsonapi-suite.github.io/jsonapi_suite/).

For benchmarks against alternatives, see https://github.com/rails-api/active_model_serializers/tree/benchmarks



## Semantic Versioning

This project adheres to [semver](http://semver.org/)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

[Back to Guides](../README.md)

# Integrating with Ember and JSON API

 - [Preparation](./ember-and-json-api.md#preparation)
 - [Server-Side Changes](./ember-and-json-api.md#server-side-changes)
 - [Adapter Changes](./ember-and-json-api.md#adapter-changes)
   - [Serializer Changes](./ember-and-json-api.md#serializer-changes)
 - [Including Nested Resources](./ember-and-json-api.md#including-nested-resources)

## Preparation

Note: This guide assumes that `ember-cli` is used for your ember app.

The JSON API specification calls for hyphens for multi-word separators. ActiveModelSerializers uses underscores.
To solve this, in Ember, both the adapter and the serializer will need some modifications:

### Server-Side Changes

First, set the adapter type in an initializer file:

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.adapter = :json_api
```

or:

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi
```

You will also want to set the `key_transform` to `:unaltered` since you will adjust the attributes in your Ember serializer to use underscores instead of dashes later. You could also use `:underscore`, but `:unaltered` is better for performance.

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.key_transform = :unaltered
```

Lastly, in order to properly handle JSON API responses, we need to register a JSON API renderer, like so:

```ruby
# config/initializers/active_model_serializers.rb
require 'active_model_serializers/register_jsonapi_renderer'
```

### Adapter Changes

```javascript
// app/adapters/application.js
import DS from 'ember-data';
import ENV from "../config/environment";

export default  DS.JSONAPIAdapter.extend({
  namespace: 'api',
  // if your rails app is on a different port from your ember app
  // this can be helpful for development.
  // in production, the host for both rails and ember should be the same.
  host: ENV.host,

  // allows the multiword paths in urls to be underscored
  pathForType: function(type) {
    let underscored = Ember.String.underscore(type);
    return Ember.String.pluralize(underscored);
  },

  // allows queries to be sent along with a findRecord
  // hopefully Ember / EmberData will soon have this built in
  // ember-data issue tracked here:
  // https://github.com/emberjs/data/issues/3596
  urlForFindRecord(id, modelName, snapshot) {
    let url = this._super(...arguments);
    let query = Ember.get(snapshot, 'adapterOptions.query');
    if(query) {
      url += '?' + Ember.$.param(query);
    }
    return url;
  }
});
```

### Serializer Changes

```javascript
// app/serializers/application.js
import Ember from 'ember';
import DS from 'ember-data';
var underscore = Ember.String.underscore;

export default DS.JSONAPISerializer.extend({
  keyForAttribute: function(attr) {
    return underscore(attr);
  },

  keyForRelationship: function(rawKey) {
    return underscore(rawKey);
  }
});

```

## Including Nested Resources

Previously, `store.find` and `store.findRecord` did not allow specification of any query params.
The ActiveModelSerializers default for the `include` parameter is to be `nil` meaning that if any associations are defined in your serializer, only the `id` and `type` will be in the `relationships` structure of the JSON API response.
For more on `include` usage, see: [The JSON API include examples](./../general/adapters.md#JSON-API)

With the above modifications, you can execute code as below in order to include nested resources while doing a find query.

```javascript
store.findRecord('post', postId, { adapterOptions: { query: { include: 'comments' } } });
```
will generate the path `/posts/{postId}?include='comments'`

So then in your controller, you'll want to be sure to have something like:
```ruby
render json: @post, include: params[:include]
```

If you want to use `include` on a collection, you'd write something like this:

```javascript
store.query('post', { include: 'comments' });
```

which will generate the path `/posts?include='comments'`

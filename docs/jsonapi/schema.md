[Back to Guides](../README.md)

[![JSON API 1.0](https://img.shields.io/badge/JSON%20API-1.0-lightgrey.svg)](http://jsonapi.org/)

## JSON API Requests

- [Query Parameters Spec](http://jsonapi.org/format/#query-parameters)

Headers:

- Request: `Accept: application/vnd.api+json`
- Response: `Content-Type: application/vnd.api+json`

### [Fetching Data](http://jsonapi.org/format/#fetching)

A server MUST support fetching resource data for every URL provided as:

- a `self` link as part of the top-level links object
- a `self` link as part of a resource-level links object
- a `related` link as part of a relationship-level links object

Example supported requests

- Individual resource or collection
  - GET /articles
  - GET /articles/1
  - GET /articles/1/author
- Relationships
  - GET /articles/1/relationships/comments
  - GET /articles/1/relationships/author
- Optional: [Inclusion of related resources](http://jsonapi.org/format/#fetching-includes) `ActiveModel::Serializer::IncludeTree`
  - GET /articles/1?`include`=comments
  - GET /articles/1?`include`=comments.author
  - GET /articles/1?`include`=author,comments.author
  - GET /articles/1/relationships/comments?`include`=comments.author
- Optional: [Sparse Fieldsets](http://jsonapi.org/format/#fetching-sparse-fieldsets) `ActiveModel::Serializer::Fieldset`
  - GET /articles?`include`=author&`fields`[articles]=title,body&`fields`[people]=name
- Optional: [Sorting](http://jsonapi.org/format/#fetching-sorting)
  - GET /people?`sort`=age
  - GET /people?`sort`=age,author.name
  - GET /articles?`sort`=-created,title
- Optional: [Pagination](http://jsonapi.org/format/#fetching-pagination)
  - GET /articles?`page`[number]=3&`page`[size]=1
- Optional: [Filtering](http://jsonapi.org/format/#fetching-filtering)
  - GET /comments?`filter`[post]=1
  - GET /comments?`filter`[post]=1,2
  - GET /comments?`filter`[post]=1,2

### [CRUD Actions](http://jsonapi.org/format/#crud)

### [Asynchronous Processing](http://jsonapi.org/recommendations/#asynchronous-processing)

### [Bulk Operations Extension](http://jsonapi.org/extensions/bulk/)

## JSON API Document Schema

| JSON API object       | JSON API properties                                                                                | Required | ActiveModelSerializers representation |
|-----------------------|----------------------------------------------------------------------------------------------------|----------|---------------------------------------|
| schema                | oneOf (success, failure, info)                                                                     |          |
| success               | data, included, meta, links, jsonapi                                                               |          | AM::SerializableResource
| success.meta          | meta                                                                                               |          | AM::S::Adapter::Base#meta
| success.included      | UniqueArray(resource)                                                                              |          | AM::S::Adapter::JsonApi#serializable_hash_for_collection
| success.data          | data                                                                                               |          |
| success.links         | allOf (links, pagination)                                                                          |          | AM::S::Adapter::JsonApi#links_for
| success.jsonapi       | jsonapi                                                                                            |          |
| failure               | errors, meta, jsonapi                                                                              | errors   |
| failure.errors        | UniqueArray(error)                                                                                 |          | #1004
| meta                  | Object                                                                                             |          |
| data                  | oneOf (resource, UniqueArray(resource))                                                            |          | AM::S::Adapter::JsonApi#serializable_hash_for_collection,#serializable_hash_for_single_resource
| resource              | String(type), String(id),<br>attributes, relationships,<br>links, meta                                   | type, id | AM::S::Adapter::JsonApi#primary_data_for
| links                 | Uri(self), Link(related)                                                                           |          | #1028, #1246, #1282
| link                  | oneOf (linkString, linkObject)                                                                     |          |
| link.linkString       | Uri                                                                                                |          |
| link.linkObject       | Uri(href), meta                                                                                    | href     |
| attributes            | patternProperties(<br>`"^(?!relationships$|links$)\\w[-\\w_]*$"`),<br>any valid JSON                      |          | AM::Serializer#attributes, AM::S::Adapter::JsonApi#resource_object_for
| relationships         | patternProperties(<br>`"^\\w[-\\w_]*$"`);<br>links, relationships.data, meta                              |          | AM::S::Adapter::JsonApi#relationships_for
| relationships.data    | oneOf (relationshipToOne, relationshipToMany)                                                      |          | AM::S::Adapter::JsonApi#resource_identifier_for
| relationshipToOne     | anyOf(empty, linkage)                                                                              |          |
| relationshipToMany    | UniqueArray(linkage)                                                                               |          |
| empty                 | null                                                                                               |          |
| linkage               | String(type), String(id), meta                                                                     | type, id | AM::S::Adapter::JsonApi#primary_data_for
| pagination            | pageObject(first), pageObject(last),<br>pageObject(prev), pageObject(next)                            |          | AM::S::Adapter::JsonApi::PaginationLinks#serializable_hash
| pagination.pageObject | oneOf(Uri, null)                                                                                   |          |
| jsonapi               | String(version), meta                                                                              |          | AM::S::Adapter::JsonApi::ApiObjects::JsonApi
| error                 | String(id), links, String(status),<br>String(code), String(title),<br>String(detail), error.source, meta |          |
| error.source          | String(pointer), String(parameter)                                                                 |          |
| pointer               | [JSON Pointer RFC6901](https://tools.ietf.org/html/rfc6901)                                        |          |


The [http://jsonapi.org/schema](schema/schema.json) makes a nice roadmap.

### Success Document
- [ ] success
  - [ ] data: `"$ref": "#/definitions/data"`
  - [ ] included: array of unique items of type `"$ref": "#/definitions/resource"`
  - [ ] meta: `"$ref": "#/definitions/meta"`
  - [ ] links:
    - [ ] link: `"$ref": "#/definitions/links"`
    - [ ] pagination: ` "$ref": "#/definitions/pagination"`
  - [ ] jsonapi: ` "$ref": "#/definitions/jsonapi"`

### Failure Document

- [ ] failure
  - [ ] errors: array of unique items of type ` "$ref": "#/definitions/error"`
  - [ ] meta:  `"$ref": "#/definitions/meta"`
  - [ ] jsonapi: `"$ref": "#/definitions/jsonapi"`

### Info Document

- [ ] info
  - [ ] meta: `"$ref": "#/definitions/meta"`
  - [ ] links: `"$ref": "#/definitions/links"`
  - [ ] jsonapi: ` "$ref": "#/definitions/jsonapi"`

### Definitions

- [ ] definitions:
  - [ ] meta
  - [ ] data: oneOf (resource, array of unique resources)
  - [ ] resource
    - [ ] attributes
    - [ ] relationships
      - [ ] relationshipToOne
        - [ ] empty
        - [ ] linkage
          - [ ] meta
      - [ ] relationshipToMany
        - [ ] linkage
          - [ ] meta
    - [ ] links
    - [ ] meta
  - [ ] links
    - [ ] link
      - [ ] uri
      - [ ] href, meta
  - [ ] pagination
  - [ ] jsonapi
    - [ ] meta
  - [ ] error: id, links, status, code, title: detail: source [{pointer, type}, {parameter: {description, type}], meta

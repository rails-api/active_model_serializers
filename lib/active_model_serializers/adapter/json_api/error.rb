module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class Error < Base
=begin
## http://jsonapi.org/format/#document-top-level

A document MUST contain at least one of the following top-level members:

- data: the document's "primary data"
- errors: an array of error objects
- meta: a meta object that contains non-standard meta-information.

The members data and errors MUST NOT coexist in the same document.

## http://jsonapi.org/format/#error-objects

Error objects provide additional information about problems encountered while performing an operation. Error objects MUST be returned as an array keyed by errors in the top level of a JSON API document.

An error object MAY have the following members:

- id: a unique identifier for this particular occurrence of the problem.
- links: a links object containing the following members:
- about: a link that leads to further details about this particular occurrence of the problem.
- status: the HTTP status code applicable to this problem, expressed as a string value.
- code: an application-specific error code, expressed as a string value.
- title: a short, human-readable summary of the problem that SHOULD NOT change from occurrence to occurrence of the problem, except for purposes of localization.
- detail: a human-readable explanation specific to this occurrence of the problem.
- source: an object containing references to the source of the error, optionally including any of the following members:
-  pointer: a JSON Pointer [RFC6901] to the associated entity in the request document [e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute].
-  parameter: a string indicating which query parameter caused the error.
- meta: a meta object containing non-standard meta-information about the error.

=end
        def self.attributes(attribute_name, attribute_errors)
          attribute_errors.map do |attribute_error|
            {
              source: { pointer: ActiveModelSerializers::JsonPointer.new(:attribute, attribute_name) },
              detail: attribute_error
            }
          end
        end

        def serializable_hash(*)
          @result = []
          # TECHDEBT: clean up single vs. collection of resources
          if serializer.object.respond_to?(:each)
            @result = collection_errors.flat_map do |collection_error|
              collection_error.flat_map do |attribute_name, attribute_errors|
                attribute_error_objects(attribute_name, attribute_errors)
              end
            end
          else
            @result = object_errors.flat_map do |attribute_name, attribute_errors|
              attribute_error_objects(attribute_name, attribute_errors)
            end
          end
          { root => @result }
        end

        def fragment_cache(cached_hash, non_cached_hash)
          JsonApi::FragmentCache.new.fragment_cache(root, cached_hash, non_cached_hash)
        end

        def root
          'errors'.freeze
        end

        private

        # @return [Array<symbol, Array<String>] i.e. attribute_name, [attribute_errors]
        def object_errors
          cache_check(serializer) do
            serializer.object.errors.messages
          end
        end

        def collection_errors
          cache_check(serializer) do
            serializer.object.flat_map do |elem|
              elem.errors.messages
            end
          end
        end

        def attribute_error_objects(attribute_name, attribute_errors)
          Error.attributes(attribute_name, attribute_errors)
        end
      end
    end
  end
end

module ActiveModelSerializers
  module Adapter
    class JsonApi
      # NOTE(Experimental):
      # This is an experimental feature. Both the interface and internals could be subject
      # to changes.
      module Deserialization
        module_function

        # Transform a JSON API document, containing a single data object,
        # into a hash that is ready for ActiveRecord::Base.new() and such.
        # Raises InvalidDocument if the payload is not properly formatted.
        #
        # @param [Hash|ActionController::Parameters] document
        # @param [Hash] options
        #   only: Array of symbols of whitelisted fields.
        #   except: Array of symbols of blacklisted fields.
        #   keys: Hash of translated keys (e.g. :author => :user).
        #   polymorphic: Array of symbols of polymorphic fields.
        # @return [Hash]
        #
        # @example
        #   document = {
        #     data: {
        #       id: 1,
        #       type: 'post',
        #       attributes: {
        #         title: 'Title 1',
        #         date: '2015-12-20'
        #       },
        #       associations: {
        #         author: {
        #           data: {
        #             type: 'user',
        #             id: 2
        #           }
        #         },
        #         second_author: {
        #           data: nil
        #         },
        #         comments: {
        #           data: [{
        #             type: 'comment',
        #             id: 3
        #           },{
        #             type: 'comment',
        #             id: 4
        #           }]
        #         }
        #       }
        #     }
        #   }
        #
        #   parse(document) #=>
        #     # {
        #     #   title: 'Title 1',
        #     #   date: '2015-12-20',
        #     #   author_id: 2,
        #     #   second_author_id: nil
        #     #   comment_ids: [3, 4]
        #     # }
        #
        #   parse(document, only: [:title, :date, :author],
        #                   keys: { date: :published_at },
        #                   polymorphic: [:author]) #=>
        #     # {
        #     #   title: 'Title 1',
        #     #   published_at: '2015-12-20',
        #     #   author_id: '2',
        #     #   author_type: 'people'
        #     # }
        #
        def parse!(document, options = {})
          parse(document, options) do |exception|
            fail exception
          end
        end

        # Same as parse!, but returns an empty hash instead of raising InvalidDocument
        # on invalid payloads.
        def parse(document, options = {})
          # TODO: change to jsonapi-ralis to have default conversion to flat hashes
          result = JSONAPI::Deserializable::Resource.call(document)
          # result = JSONAPI::Deserializable::ActiveRecord.new(document, options: options).to_hash
          result = apply_options(result, options)
          result
        rescue JSONAPI::Parser::InvalidDocument => e
          return {} unless block_given?
          yield e
        end

        def apply_options(hash, options)
          hash = transform_keys(hash, options) if options[:key_transform]
          hash = hash.deep_symbolize_keys
          hash = rename_fields(hash, options)
          hash
        end

        # TODO: transform the keys after parsing
        # @api private
        def transform_keys(hash, options)
          transform = options[:key_transform] || :underscore
          CaseTransform.send(transform, hash)
        end

        def rename_fields(hash, options)
          return hash unless options[:keys]

          keys = options[:keys]
          hash.each_with_object({}) do |(k, v), h|
            k = keys.fetch(k, k)
            h[k] = v
            h
          end
        end
      end
    end
  end
end

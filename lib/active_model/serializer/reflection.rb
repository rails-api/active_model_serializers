require 'active_model/serializer/field'

module ActiveModel
  class Serializer
    # Holds all the meta-data about an association as it was specified in the
    # ActiveModel::Serializer class.
    #
    # @example
    #   class PostSerializer < ActiveModel::Serializer
    #     has_one :author, serializer: AuthorSerializer
    #     has_many :comments
    #     has_many :comments, key: :last_comments do
    #       object.comments.last(1)
    #     end
    #     has_many :secret_meta_data, if: :is_admin?
    #
    #     def is_admin?
    #       current_user.admin?
    #     end
    #   end
    #
    #  Specifically, the association 'comments' is evaluated two different ways:
    #  1) as 'comments' and named 'comments'.
    #  2) as 'object.comments.last(1)' and named 'last_comments'.
    #
    #  PostSerializer._reflections #=>
    #    # [
    #    #   HasOneReflection.new(:author, serializer: AuthorSerializer),
    #    #   HasManyReflection.new(:comments)
    #    #   HasManyReflection.new(:comments, { key: :last_comments }, #<Block>)
    #    #   HasManyReflection.new(:secret_meta_data, { if: :is_admin? })
    #    # ]
    #
    # So you can inspect reflections in your Adapters.
    #
    class Reflection < Field
      def initialize(*)
        super
        @_links = {}
        @_include_data = true
      end

      def link(name, value = nil, &block)
        @_links[name] = block || value
        :nil
      end

      def meta(value = nil, &block)
        @_meta = block || value
        :nil
      end

      def include_data(value = true)
        @_include_data = value
        :nil
      end

      def value(serializer)
        @object = serializer.object
        @scope = serializer.scope

        if block
          block_value = instance_eval(&block)
          if block_value == :nil
            serializer.read_attribute_for_serialization(name)
          else
            block_value
          end
        else
          serializer.read_attribute_for_serialization(name)
        end
      end

      # Build association. This method is used internally to
      # build serializer's association by its reflection.
      #
      # @param [Serializer] subject is a parent serializer for given association
      # @param [Hash{Symbol => Object}] parent_serializer_options
      #
      # @example
      #    # Given the following serializer defined:
      #    class PostSerializer < ActiveModel::Serializer
      #      has_many :comments, serializer: CommentSummarySerializer
      #    end
      #
      #    # Then you instantiate your serializer
      #    post_serializer = PostSerializer.new(post, foo: 'bar') #
      #    # to build association for comments you need to get reflection
      #    comments_reflection = PostSerializer._reflections.detect { |r| r.name == :comments }
      #    # and #build_association
      #    comments_reflection.build_association(post_serializer, foo: 'bar')
      #
      # @api private
      #
      def build_association(subject, parent_serializer_options)
        association_value = value(subject)
        reflection_options = reflection_options(association_value, options)
        serializer_class = subject.class.serializer_for(association_value, reflection_options)
        reflection_options[:include_data] = @_include_data

        if serializer_class
          begin
            serializer = serializer_class.new(
              association_value,
              serializer_options(subject, parent_serializer_options, reflection_options)
            )
          rescue ActiveModel::Serializer::CollectionSerializer::NoSerializerError
            reflection_options[:virtual_value] = association_value.try(:as_json) || association_value
          end
        elsif !association_value.nil? && !association_value.instance_of?(Object)
          reflection_options[:virtual_value] = association_value
        end

        Association.new(name, serializer, reflection_options, @_links, @_meta)
      end

      protected

      attr_accessor :object, :scope

      private

      def polymorphic_key(assoc_value)
        reflection_key = assoc_value.class.model_name
        assoc_value.respond_to?(:each) ? reflection_key.plural : reflection_key.singular
      end

      def reflection_options(assoc_value, options)
        reflection_options = options.dup
        reflection_options[:key] = polymorphic_key(assoc_value) if options[:polymorphic] && !options.key?(:key)
        reflection_options
      end

      def serializer_options(subject, parent_serializer_options, reflection_options)
        serializer = reflection_options.fetch(:serializer, nil)

        serializer_options = parent_serializer_options.except(:serializer)
        serializer_options[:serializer] = serializer if serializer
        serializer_options[:serializer_context_class] = subject.class
        serializer_options
      end
    end
  end
end

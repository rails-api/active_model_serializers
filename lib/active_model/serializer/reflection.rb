require 'active_model/serializer/field'
require 'active_model/serializer/association'

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
    #     has_one :blog do |serializer|
    #       meta count: object.roles.count
    #       serializer.cached_blog
    #     end
    #
    #     private
    #
    #     def cached_blog
    #       cache_store.fetch("cached_blog:#{object.updated_at}") do
    #         Blog.find(object.blog_id)
    #       end
    #     end
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
    class Reflection < Field
      REFLECTION_OPTIONS = %i(key links polymorphic meta serializer virtual_value namespace).freeze

      def initialize(*)
        super
        options[:links] = {}
        options[:include_data_setting] = Serializer.config.include_data_default
        options[:meta] = nil
      end

      # @api public
      # @example
      #   has_one :blog do
      #     include_data false
      #     link :self, 'a link'
      #     link :related, 'another link'
      #     link :self, '//example.com/link_author/relationships/bio'
      #     id = object.profile.id
      #     link :related do
      #       "//example.com/profiles/#{id}" if id != 123
      #     end
      #     link :related do
      #       ids = object.likes.map(&:id).join(',')
      #       href "//example.com/likes/#{ids}"
      #       meta ids: ids
      #     end
      #   end
      def link(name, value = nil, &block)
        options[:links][name] = block || value
        :nil
      end

      # @api public
      # @example
      #   has_one :blog do
      #     include_data false
      #     meta(id: object.blog.id)
      #     meta liked: object.likes.any?
      #     link :self do
      #       href object.blog.id.to_s
      #       meta(id: object.blog.id)
      #     end
      def meta(value = nil, &block)
        options[:meta] = block || value
        :nil
      end

      # @api public
      # @example
      #   has_one :blog do
      #     include_data false
      #     link :self, 'a link'
      #     link :related, 'another link'
      #   end
      #
      #   has_one :blog do
      #     include_data false
      #     link :self, 'a link'
      #     link :related, 'another link'
      #   end
      #
      #    belongs_to :reviewer do
      #      meta name: 'Dan Brown'
      #      include_data true
      #    end
      #
      #    has_many :tags, serializer: TagSerializer do
      #      link :self, '//example.com/link_author/relationships/tags'
      #      include_data :if_sideloaded
      #    end
      def include_data(value = true)
        options[:include_data_setting] = value
        :nil
      end

      # Build association. This method is used internally to
      # build serializer's association by its reflection.
      #
      # @param [Serializer] parent_serializer for given association
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
      def build_association(parent_serializer, parent_serializer_options, include_slice = {})
        reflection_options = options.dup.reject { |k, _| !REFLECTION_OPTIONS.include?(k) }
        association_options = build_association_options(parent_serializer, parent_serializer_options, include_slice)
        association_value = association_options[:association_value]
        serializer_class = association_options[:association_serializer]
        reflection_options[:include_data] = include_data?(include_slice) # Needs to be after association_value is evaluated unless reflection.block.nil?
        reflection_options[:meta] = options[:meta] # meta is mutated when the association_value is evaluated

        if serializer_class
          serializer = catch(:no_serializer) do
            serializer_options = parent_serializer_options.except(:serializer, :association_value, :association_serializer, :include_data)
            serializer_options[:serializer_context_class] = parent_serializer.class
            serializer = reflection_options.fetch(:serializer, nil)
            serializer_options[:serializer] = serializer if serializer
            serializer_class.new(association_value, serializer_options)
          end
          if serializer
            reflection_options[:serializer] = serializer
          else
            reflection_options[:virtual_value] = association_value.try(:as_json) || association_value
          end
        elsif !association_value.nil? && !association_value.instance_of?(Object)
          reflection_options[:virtual_value] = association_value
        end

        association_block = nil
        Association.new(name, reflection_options, association_block)
      end

      protected

      # used in instance exec
      attr_accessor :object, :scope

      def serializer?
        options.key?(:serializer)
      end

      def serializer
        options[:serializer]
      end

      def namespace
        options[:namespace]
      end

      def include_data?(include_slice)
        include_data_setting = options[:include_data_setting]
        case include_data_setting
        when :if_sideloaded then include_slice.key?(name)
        when true           then true
        when false          then false
        else fail ArgumentError, "Unknown include_data_setting '#{include_data_setting.inspect}'"
        end
      end

      # @param serializer [ActiveModel::Serializer]
      # @yield [ActiveModel::Serializer]
      # @return [:nil, associated resource or resource collection]
      def value(serializer, include_slice)
        @object = serializer.object
        @scope = serializer.scope

        block_value = instance_exec(serializer, &block) if block
        return unless include_data?(include_slice)

        if block && block_value != :nil
          block_value
        else
          serializer.read_attribute_for_serialization(name)
        end
      end

      def build_association_options(parent_serializer, parent_serializer_options, include_slice)
        serializer_for_options = {
          # Pass the parent's namespace onto the child serializer
          namespace: namespace || parent_serializer_options[:namespace]
        }
        serializer_for_options[:serializer] = serializer if serializer?
        association_value = value(parent_serializer, include_slice)
        parent_serializer_options.merge(
          association_value: association_value,
          association_serializer: parent_serializer.class.serializer_for(association_value, serializer_for_options),
        )
      end
    end
  end
end

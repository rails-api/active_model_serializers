require 'singleton'

module ActiveModel
  class Serializer
    class Configuration
      class Null
        include Singleton

        def method_missing(*)
          nil
        end

        def respond_to?(*)
          true
        end
      end

      attr_accessor :parent

      class << self
        def global
          @global ||= new default_options
        end

        def default_options
          { embed: :objects }
        end
      end

      def build(options = {})
        self.class.new options, self
      end

      def initialize(options = {}, parent = Null.instance)
        @root          = read_option options, :root
        @embed         = read_option options, :embed
        @embed_in_root = read_option options, :embed_in_root
        @parent        = parent
      end

      def root
        return_first @root, parent.root
      end

      def embed
        return_first @embed, parent.embed
      end

      def embed_in_root
        return_first @embed_in_root, parent.embed_in_root
      end

      # FIXME: Get rid of this mess.
      def embed_objects=(value)
        @embed = :objects if value
      end

      # FIXME: Get rid of this mess.
      def embed_ids=(value)
        @embed = :ids if value
      end

      def embed_objects
        [:objects, :object].include? embed
      end

      def embed_ids
        [:ids, :id].include? embed
      end

      private

      def read_option(options, name)
        options[name] || false if options.has_key? name
      end

      def return_first(*values)
        values.compact.first
      end
    end
  end
end

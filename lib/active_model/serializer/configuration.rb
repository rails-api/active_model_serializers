require 'singleton'

module ActiveModel
  class Serializer
    class Configuration
      class << self
        def valid_options
          @valid_options ||= []
        end

        def options(*names)
          valid_options.concat names

          names.each do |name|
            attr_writer name

            define_method name do
              option name
            end
          end
        end
        alias option options
      end

      attr_accessor :parent

      def initialize(parent, options = {})
        self.parent = parent

        default_options.merge!(options).each do |name, value|
          send "#{name}=", value
        end
      end

      def default_options
        {}
      end

      private

      def own_option(name)
        instance_variable_get "@#{name}"
      end

      def parent_option(name)
        parent.send name if parent.respond_to? name
      end

      def option(name)
        value = own_option name
        value.nil? ? parent_option(name) : value
      end
    end

    class SerializerConfiguration < Configuration
      options :root, :embed, :embed_in_root

      def default_options
        { embed: :objects }
      end
    end

    class GlobalConfiguration < Configuration
      include Singleton

      options :root, :embed, :embed_in_root

      def initialize
        super nil
      end

      def default_options
        { embed: :objects }
      end
    end

    class ClassConfiguration < Configuration
      options :root, :embed, :embed_in_root

      def default_options
        { embed: :objects }
      end

      def embed_objects=(value)
        @embed = :objects if value
      end

      def embed_ids=(value)
        @embed = :ids if value
      end

      def embed_objects
        [:objects, :object].include? embed
      end

      def embed_ids
        [:ids, :id].include? embed
      end
    end

    class InstanceConfiguration < Configuration
      options :root, :embed, :embed_in_root, :scope, :meta, :meta_key, :wrap_in_array,
        :serializer, :prefixes, :template, :layout

      def default_options
        { embed: :objects, meta_key: :meta }
      end
    end

    class ArrayConfiguration < Configuration
      options :root, :embed, :embed_in_root, :scope, :meta, :meta_key, :wrap_in_array,
        :serializer, :prefixes, :template, :layout, :each_serializer, :resource_name

      def default_options
        { embed: :objects, meta_key: :meta }
      end
    end
  end
end

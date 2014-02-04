module Rails
  module Generators
    class SerializerGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)
      check_class_collision suffix: 'Serializer'

      argument :attributes, type: :array, default: [], banner: 'field:type field:type'

      class_option :parent, type: :string, desc: 'The parent class for the generated serializer'

      def create_serializer_file
        template 'serializer.rb', File.join('app/serializers', class_path, "#{file_name}_serializer.rb")
      end

      private

      def attributes_names
        [:id] + attributes.select { |attr| !attr.reference? }.map { |a| a.name.to_sym }
      end

      def association_names
        attributes.select { |attr| attr.reference? }.map { |a| a.name.to_sym }
      end

      def parent_class_name
        if options[:parent]
          options[:parent]
        elsif (ns = Rails::Generators.namespace) && ns.const_defined?(:ApplicationSerializer) ||
               (Object.const_get(:ApplicationSerializer) rescue nil)
          'ApplicationSerializer'
        else
          'ActiveModel::Serializer'
        end
      end
    end
  end
end

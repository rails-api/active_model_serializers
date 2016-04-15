module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def initialize(serializer, options = {})
        super
        @include_tree = ActiveModel::Serializer::IncludeTree.from_include_args(options[:include] || '*')
      end

      def serializable_hash(options = nil)
        options = serialization_options(options)

        if serializer.respond_to?(:each)
          serializer.map do |element|
            element.serialize(options, instance_options, self, @include_tree)
          end
        else
          serializer.serialize(options, instance_options, self, @include_tree)
        end
      end
    end
  end
end

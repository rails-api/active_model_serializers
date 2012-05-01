require "rails/generators"
require "rails/generators/rails/resource/resource_generator"

module Rails
  module Generators
    ResourceGenerator.class_eval do
      def add_serializer
        invoke "serializer"
      end
    end
  end
end


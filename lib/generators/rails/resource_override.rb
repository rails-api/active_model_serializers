require 'rails/generators'
require 'rails/generators/rails/resource/resource_generator'

module Rails
  module Generators
    class ResourceGenerator
      hook_for :serializer, default: true, boolean: true
    end
  end
end

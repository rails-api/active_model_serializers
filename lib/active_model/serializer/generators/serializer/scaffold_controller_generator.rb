require 'rails/generators'
require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    class ScaffoldControllerGenerator
      if Rails::VERSION::MAJOR >= 4
        source_root File.expand_path('../templates', __FILE__)

        hook_for :serializer, default: true
      end
    end
  end
end

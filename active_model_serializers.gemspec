# -*- encoding: utf-8 -*-

$:.unshift File.expand_path("../lib", __FILE__)
require "active_model/serializer/version"

Gem::Specification.new do |gem|
  gem.authors       = ["José Valim", "Yehuda Katz", "Santiago Pastorino"]
  gem.email         = ["jose.valim@gmail.com", "wycats@gmail.com", "santiago@wyeworks.com"]
  gem.description   = %q{Making it easy to serialize models for client-side use}
  gem.summary       = %q{Bringing consistency and object orientation to model serialization. Works great for client-side MVC frameworks!}
  gem.homepage      = "https://github.com/rails-api/active_model_serializers"
  gem.license       = 'MIT'

  gem.files         = Dir['README.md', 'CHANGELOG.md', 'CONTRIBUTING.md', 'DESIGN.textile', 'MIT-LICENSE', 'lib/**/*', 'test/**/*']
  gem.test_files    = Dir['test/**/*']

  gem.name          = "active_model_serializers"
  gem.require_paths = ["lib"]
  gem.version       = ActiveModel::Serializer::VERSION

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency "activemodel", ">= 3.2"
  gem.add_development_dependency "rails", ">= 3.2"
end

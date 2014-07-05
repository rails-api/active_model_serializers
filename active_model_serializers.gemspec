# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_model_serializers/version'

Gem::Specification.new do |spec|
  spec.name          = "active_model_serializers"
  spec.version       = ActiveModelSerializers::VERSION
  spec.authors       = ["Steve Klabnik"]
  spec.email         = ["steve@steveklabnik.com"]
  spec.summary       = %q{Conventions-based JSON generation for Rails.}
  spec.description   = %q{ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner.}
  spec.homepage      = "https://github.com/rails-api/active_model_serializers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end

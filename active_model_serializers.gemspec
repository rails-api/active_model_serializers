# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'active_model_serializers'
  spec.version       = "1.0.0-dev"
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Steve Klabnik']
  spec.email         = ['steve@steveklabnik.com']
  spec.summary       = 'Conventions-based JSON generation for Rails.'
  spec.description   = 'ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner.'
  spec.homepage      = 'https://github.com/rails-api/active_model_serializers'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.executables   = []

  spec.required_ruby_version = '>= 2.1'
end

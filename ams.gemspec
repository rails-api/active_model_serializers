# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ams/version'

Gem::Specification.new do |spec|
  spec.name          = 'ams'
  spec.version       = AMS::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Benjamin Fleischer']
  spec.email         = ['dev@benjaminfleischer.com']
  spec.summary       = 'Conventions-based JSON generation for Rails.'
  spec.description   = 'AMS allows you to generate your JSON in an object-oriented and convention-driven manner.'
  spec.homepage      = 'https://github.com/bf4/ams'
  spec.license       = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    # 'wiki_uri'          => nil,
    # 'documentation_uri' => nil,
    # 'mailing_list_uri'  => nil,
    'source_code_uri'   => spec.homepage,
    'bug_tracker_uri'   => spec.homepage + '/issues'
  }

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.executables   = []
  spec.extensions    = []

  spec.required_ruby_version = '>= 2.1'

  # rails_versions = ['>= 4.1', '< 6']
  # spec.add_runtime_dependency 'activemodel', rails_versions
  # 'activesupport', rails_versions
  # 'builder'

  # 'activesupport', rails_versions
  # 'i18n,
  # 'tzinfo'
  # 'minitest'
  # 'thread_safe'

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'minitest', '~> 5'
end

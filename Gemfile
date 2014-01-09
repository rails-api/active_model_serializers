source 'https://rubygems.org'

# Specify gem dependencies in active_model_serializers.gemspec
gemspec

platforms :ruby do
  gem 'sqlite3'
end

platforms :mri do
  gem 'coveralls', require: false
  gem 'simplecov', require: false
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :rbx do
  gem 'json'
  gem 'rubysl', '~> 2.0'
  gem 'racc', '~> 1.4.10'
end

gem 'rails', '~> 4.0.0'

source 'https://rubygems.org'

# Specify gem dependencies in active_model_serializers.gemspec
gemspec

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

gem 'coveralls', :require => false
gem 'simplecov', :require => false

gem 'rails', "~> 4.0.0"

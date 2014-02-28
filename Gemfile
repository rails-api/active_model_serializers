source 'https://rubygems.org'

gemspec

platforms :ruby do
  # sqlite3 1.3.9 does not work with rubinius 2.2.5:
  # https://github.com/sparklemotion/sqlite3-ruby/issues/122
  gem 'sqlite3', '1.3.8'
end

platforms :mri do
  gem 'coveralls', require: false
  gem 'simplecov', require: false
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

gem 'rails', '~> 4.0.0'

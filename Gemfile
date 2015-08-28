source 'https://rubygems.org'

# Specify your gem's dependencies in active_model_serializers.gemspec
gemspec

version = ENV['RAILS_VERSION'] || '4.2'

if version == 'master'
  gem 'rack', github: 'rack/rack'
  git 'https://github.com/rails/rails.git' do
    gem 'railties'
    gem 'activesupport'
    gem 'activemodel'
    gem 'actionpack'
    # Rails 5
    gem 'actionview'
  end
  # Rails 5
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing'
else
  gem_version = "~> #{version}.0"
  gem 'railties', gem_version
  gem 'activesupport', gem_version
  gem 'activemodel', gem_version
  gem 'actionpack', gem_version
end

group :test do
  gem 'activerecord'
  gem 'sqlite3', platform: :ruby
  gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
  gem 'codeclimate-test-reporter', require: false
end

group :test, :development do
  gem 'simplecov', '~> 0.10', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem 'rubocop', '~> 0.33.0', require: false
end

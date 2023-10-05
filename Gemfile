# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

#
# Add a Gemfile.local to locally bundle gems outside of version control
local_gemfile = File.join(File.expand_path('..', __FILE__), 'Gemfile.local')
eval_gemfile local_gemfile if File.readable?(local_gemfile)

# Specify your gem's dependencies in active_model_serializers.gemspec
gemspec

version = ENV['RAILS_VERSION'] || '6.1'

if version == 'master'
  gem 'rack', github: 'rack/rack'
  gem 'arel', github: 'rails/arel'
  gem 'rails', github: 'rails/rails'
  git 'https://github.com/rails/rails.git' do
    gem 'railties'
    gem 'activesupport'
    gem 'activemodel'
    gem 'actionpack'
    gem 'activerecord', group: :test
    # Rails 5
    gem 'actionview'
  end
else
  gem_version = "~> #{version}.0"
  gem 'rails', gem_version
  gem 'railties', gem_version
  gem 'activesupport', gem_version
  gem 'activemodel', gem_version
  gem 'actionpack', gem_version
  gem 'activerecord', gem_version, group: :test
end

# https://github.com/bundler/bundler/blob/89a8778c19269561926cea172acdcda241d26d23/lib/bundler/dependency.rb#L30-L54
@windows_platforms = [:mswin, :mingw, :x64_mingw]

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: (@windows_platforms + [:jruby])

if ENV['CI']
  if RUBY_VERSION < '2.4'
    # Windows: An error occurred while installing nokogiri (1.8.0)
    gem 'nokogiri', '< 1.7', platforms: @windows_platforms
  end
end

group :bench do
  # https://github.com/rails-api/active_model_serializers/commit/cb4459580a6f4f37f629bf3185a5224c8624ca76
  gem 'benchmark-ips', '>= 2.7.2', require: false, group: :development
end

group :test do
  platforms(*(@windows_platforms + [:ruby])) do
    if version == 'master' || version >= '6'
      gem 'sqlite3', '< 1.6'
    else
      gem 'sqlite3', '~> 1.3.13'
    end
  end
  platforms :jruby do
    if version == 'master' || version >= '6.0'
      gem 'activerecord-jdbcsqlite3-adapter', github: 'jruby/activerecord-jdbc-adapter'
    elsif version == '5.2'
      gem 'activerecord-jdbcsqlite3-adapter', '~> 52.0'
    elsif version == '5.1'
      gem 'activerecord-jdbcsqlite3-adapter', '~> 51.0'
    elsif version == '5.0'
      gem 'activerecord-jdbcsqlite3-adapter', '~> 50.0'
    else
      gem 'activerecord-jdbcsqlite3-adapter', '~> 1.3.0'
    end
  end
  gem 'codeclimate-test-reporter', require: false
  gem 'm', '~> 1.5'
  gem 'pry', '>= 0.10'
  gem 'byebug', '~> 8.2' if RUBY_VERSION < '2.2'
end

group :development, :test do
  if RUBY_VERSION < '3.0'
    gem 'rubocop', '~> 0.40.0', require: false
  else
    gem 'rubocop', '~> 1.56.0', require: false
    gem 'rubocop-minitest', '~> 0.31.0', require: false
    gem 'rubocop-rails', '~> 2.20.0', require: false
    gem 'rubocop-rake', '~> 0.6.0', require: false
  end
  if version <= '5.0'
    gem 'loofah', '< 2.21.0'
    gem 'rails-html-sanitizer', '< 1.6.0'
  end
  gem 'yard', require: false
end

source 'https://rubygems.org'
#
# Add a Gemfile.local to locally bundle gems outside of version control
local_gemfile = File.join(File.expand_path('..', __FILE__), 'Gemfile.local')
eval_gemfile local_gemfile if File.readable?(local_gemfile)

# Specify your gem's dependencies in active_model_serializers.gemspec
gemspec

version = ENV['RAILS_VERSION'] || '4.2'

if version == 'master'
  gem 'rack', github: 'rack/rack'
  gem 'arel', github: 'rails/arel'
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

group :test do
  gem 'sqlite3',                          platform: (@windows_platforms + [:ruby])
  gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby

  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', '~> 0.10', require: false, group: :development
end

group :development, :test do
  gem 'rubocop', '~> 0.36', require: false
end

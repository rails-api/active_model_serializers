source 'https://rubygems.org'

gemspec

version = ENV["RAILS_VERSION"] || "7.0"

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
  # Rails 5
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing'
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
tzinfo_platforms = @windows_platforms
tzinfo_platforms += [:jruby] if version >= '4.1'
gem 'tzinfo-data', platforms: tzinfo_platforms

group :bench do
  gem 'benchmark-ips', '>= 2.7.2'
end

group :test do
  platforms(*(@windows_platforms + [:ruby])) do
    if version == 'master' || version >= '6'
      gem 'sqlite3'
    else
      gem 'sqlite3', '~> 1.3.13'
    end
  end
end

group :development, :test do
  unless ENV['CI']
    gem 'rubocop', '~> 0.34.0', require: false
  end
  
  # 0.12 requires ruby 2.4
  if RUBY_VERSION < '2.4'
    gem 'simplecov', '< 0.12', require: false
  else
    gem 'simplecov', '~> 0.10', require: false
  end
end

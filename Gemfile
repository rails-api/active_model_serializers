source 'https://rubygems.org'

gemspec

version = ENV["RAILS_VERSION"] || "4.2"

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

if RUBY_VERSION < '2'
  gem 'mime-types', [ '>= 2.6.2', '< 3' ]
end

if ENV['CI']
  if RUBY_VERSION < '2.4'
    # Windows: An error occurred while installing nokogiri (1.8.0)
    gem 'nokogiri', '< 1.7', platforms: @windows_platforms
  end

  if RUBY_VERSION < '2.2'
    # >= 12.3 and < 13 requires ruby >= 2.0, rake >= 13 requires ruby >= 2.2
    gem 'rake', '< 12.3' 
  end
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
      gem 'sqlite3', '~> 1.4'
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
  gem 'simplecov', '~> 0.10', require: false, group: :development
end

group :development, :test do
  gem 'rubocop', '~> 0.34.0', require: false
end

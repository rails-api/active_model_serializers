source 'https://rubygems.org'

version = ENV['RAILS_VERSION']
if version == 'master'
  gem 'rails', github: 'rails/rails'
elsif version
  gem_version = "~> #{version}.0"
  gem 'rails', gem_version
else
  gem 'rails'
end

gemspec

gem 'tzinfo-data', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

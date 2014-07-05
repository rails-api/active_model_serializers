source 'https://rubygems.org'

# Specify your gem's dependencies in active_model_serializers.gemspec
gemspec

gem "minitest"

version = ENV["RAILS_VERSION"] || "4.0"

if version == "master"
  gem "rails", github: "rails/rails"
else
  gem "rails", "~> #{version}"
end

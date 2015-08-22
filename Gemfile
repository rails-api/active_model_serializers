source 'https://rubygems.org'

# Specify your gem's dependencies in active_model_serializers.gemspec
gemspec

group :development do
  gem "minitest"
  gem "sqlite3", platform: :ruby
  gem "activerecord-jdbcsqlite3-adapter", platform: :jruby
end

version = ENV["RAILS_VERSION"] || "4.2"

if version == "master"
  gem "rails", github: "rails/rails"

  # ugh https://github.com/rails/rails/issues/16063#issuecomment-48090125
  gem "arel", github: "rails/arel"
else
  gem "rails", "~> #{version}.0"
end

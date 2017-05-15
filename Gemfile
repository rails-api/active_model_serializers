# frozen_string_literal: true
source "https://rubygems.org"
gemspec

group :test do
  gem "m", "~> 1.5"
  gem "pry", "~> 0.10"
  gem "pry-byebug", "~> 3.4", platform: :ruby
end

group :development, :test do
  gem "rubocop", ">= 0.47", require: false
  gem "yard", require: false
end

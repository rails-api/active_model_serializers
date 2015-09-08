# https://github.com/colszowka/simplecov/pull/400
# https://github.com/ruby/ruby/blob/trunk/lib/English.rb
unless defined?(English)
  # The exception object passed to +raise+.
  alias $ERROR_INFO $! # rubocop:disable Style/SpecialGlobalVars
end

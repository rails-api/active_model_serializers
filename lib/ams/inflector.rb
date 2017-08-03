# frozen_string_literal: true

# Adapted from
# https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb
# https://github.com/mbj/inflecto/blob/master/lib/inflecto.rb
module AMS
  begin
    require "active_support/inflector/methods"
    # :nocov:
    Inflector = ActiveSupport::Inflector
    # :nocov:
  rescue LoadError
    module Inflector
      extend self

      # Makes an underscored, lowercase form from the expression in the string.
      #
      # Changes '::' to '/' to convert namespaces to paths.
      #
      #   underscore('ActiveModel')         # => "active_model"
      #   underscore('ActiveModel::Errors') # => "active_model/errors"
      #
      # As a rule of thumb you can think of +underscore+ as the inverse of
      # #camelize, though there are cases where that does not hold:
      #
      #   camelize(underscore('SSLError'))  # => "SslError"
      def underscore(camel_cased_word)
        return camel_cased_word unless /[A-Z-]|::/.match(camel_cased_word)
        word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
        word.tr!("-".freeze, "_".freeze)
        word.downcase!
        word
      end

      def pluralize(word)
        if word.end_with?("s")
          "#{word}es"
        else
          "#{word}s"
        end
      end

      def singularize(word)
        if word.end_with?("es")
          word[0..-3]
        elsif word.end_with?("s")
          word[0..-2]
        else
          word
        end
      end
    end
  end
end

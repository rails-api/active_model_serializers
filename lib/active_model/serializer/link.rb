# frozen_string_literal: true

require 'active_model/serializer/field'

module ActiveModel
  class Serializer
    # Holds all the data about a serializer link
    #
    # @example
    #   class PostSerializer < ActiveModel::Serializer
    #     link :callback, if: :internal? do
    #       object.callback_link
    #     end
    #
    #     def internal?
    #       instance_options[:internal] == true
    #     end
    #   end
    #
    class Link < Field
    end
  end
end

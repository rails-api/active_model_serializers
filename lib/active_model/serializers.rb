module ActiveModel
  module Serializers
    class StringSerializer < ActiveModel::Serializer
      def attributes(obj)
        @object.to_s
      end
    end
  end
end

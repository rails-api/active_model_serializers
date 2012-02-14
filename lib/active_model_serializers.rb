#--
# Copyright (c) 2011-2012 José Valim http://blog.plataformatec.com.br
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "active_support"
require "active_support/core_ext/string/inflections"
require "active_model"
require "active_model/serializer"

module ActiveModel::SerializerSupport
  extend ActiveSupport::Concern

  module ClassMethods #:nodoc:
    if "".respond_to?(:safe_constantize)
      def active_model_serializer
        @active_model_serializer ||= "#{self.name}Serializer".safe_constantize
      end
    else
      def active_model_serializer
        return @active_model_serializer if defined?(@active_model_serializer)

        begin
          @active_model_serializer = "#{self.name}Serializer".constantize
        rescue NameError => e
          raise unless e.message =~ /uninitialized constant/
        end
      end
    end
  end

  # Returns a model serializer for this object considering its namespace.
  def active_model_serializer
    self.class.active_model_serializer
  end

  alias :read_attribute_for_serialization :send
end

ActiveSupport.on_load(:active_record) do
  include ActiveModel::SerializerSupport
end

begin
  require 'action_controller'
  require 'action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end
rescue LoadError => ex
  # rails on installed, continuing
end

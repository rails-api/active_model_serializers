module ActiveModel
  class Serializer
    module AttributeMethods
      extend ActiveSupport::Concern

      class Cache
        def initialize
          @module = Module.new
          @method_cache = ThreadSafe::Cache.new
        end

        def [](name)
          @method_cache.compute_if_absent(name) do
            safe_name = name.to_s.unpack('h*').first
            temp_method = "__temp__#{safe_name}"
            ActiveModel::Serializer::AttributeMethods::AttrNames.set_name_cache safe_name, name
            @module.module_eval method_body(temp_method, safe_name), __FILE__, __LINE__
            @module.instance_method temp_method
          end
        end

        private

        def method_body(method_name, const_name)
          <<-EOMETHOD
          def #{method_name}
            name = ::ActiveModel::Serializer::AttributeMethods::AttrNames::ATTR_#{const_name}
            object && object.read_attribute_for_serialization(name)
          end
          EOMETHOD
        end
      end

      MethodCache = Cache.new

      module AttrNames
        def self.set_name_cache(name, value)
          const_name = "ATTR_#{name}"
          unless const_defined? const_name
            const_set const_name, value.duplicable? ? value.dup.freeze : value
          end
        end
      end

      module ClassMethods
        attr_accessor :_attributes

        def inherited(base)
          base._attributes = []
        end

        def attributes(*attrs)
          @_attributes.concat attrs

          attrs.each do |attr|
            unless generated_attribute_methods.method_defined?(attr)
              generated_attribute_methods.module_exec do
                define_method(attr, MethodCache[attr])
              end
            end
          end
        end

        def attribute(attr, options = {})
          key = options.fetch(:key, attr)
          @_attributes << key
          unless generated_attribute_methods.method_defined?(key)
            generated_attribute_methods.module_exec do
              define_method(key, MethodCache[attr])
            end
          end
        end

        protected

        private

        def generated_attribute_methods #:nodoc:
          @generated_attribute_methods ||= Module.new {
            extend Mutex_m
          }.tap { |mod| include mod }
        end
      end
    end
  end
end

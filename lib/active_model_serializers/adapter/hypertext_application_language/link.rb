module ActiveModelSerializers
  module Adapter
    class HypertextApplicationLanguage
      class Link
        include SerializationContext::UrlHelpers

        def initialize(serializer, value)
          # handles warning actionpack-4.0.13/lib/action_dispatch/routing/route_set.rb
          # warning: instance variable @_routes not initialized
          @_routes ||= nil

          @object = serializer.object
          @scope = serializer.scope
          @value = value.respond_to?(:call) ? instance_eval(&value) : value
        end

        def href(value)
          @href = value
          nil
        end

        def templated(value)
          @templated = value
          nil
        end

        def type(value)
          @type = value
          nil
        end

        def deprecation(value)
          @deprecation = value
          nil
        end

        def name(value)
          @name = value
          nil
        end

        def profile(value)
          @profile = value
          nil
        end

        def title(value)
          @title = value
          nil
        end

        def hreflang(value)
          @hreflang = value
          nil
        end

        def as_json
          hash = {}
          hash[:href] = @value || @href
          hash[:templated] = @templated
          hash[:type] = @type
          hash[:deprecation] = @deprecation
          hash[:name] = @name
          hash[:profile] = @profile
          hash[:title] = @title
          hash[:hreflang] = @hreflang

          hash.compact
        end

        protected

        attr_reader :object, :scope
      end
    end
  end
end

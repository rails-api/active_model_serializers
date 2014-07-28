module Shoulda # :nodoc:
  module ActiveModel
    module Serializer
      module Matchers # :nodoc:
        # Ensures a response uses the given serializer.
        #
        # Example:
        #
        #   it { should use_serializer(UserSerializer)  }
        def use_serializer(serializer)
          UseSerializerMatcher.new(serializer).in_context(self)
        end

        class UseSerializerMatcher # :nodoc:
          def initialize(serializer)
            @serializer = serializer
          end

          def matches?(controller)
            @controller = controller
            uses_serializer?
          end

          def failure_message_for_should
            "Expected to render with #{@serializer}, but was not."
          end

          def failure_message_for_should_not
            "Did not expect to render with #{@serializer}."
          end

          def description
            "render with serializer #{@serializer}"
          end

          def in_context(context)
            @context = context
            self
          end

          private

          def uses_serializer?
            begin
              @context.send(:assert_serializer, @serializer)
              true
            rescue Shoulda::Matchers::AssertionError => error
              false
            end
          end
        end
      end
    end
  end
end

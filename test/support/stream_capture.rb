# Use cleaner stream testing interface from Rails 5 if available
# see https://github.com/rails/rails/blob/29959eb59d/activesupport/lib/active_support/testing/stream.rb
begin
  require 'active_support/testing/stream'
rescue LoadError
  require 'tempfile'
  module ActiveSupport
    module Testing
      module Stream #:nodoc:
        private

        def silence_stream(stream)
          old_stream = stream.dup
          stream.reopen(IO::NULL)
          stream.sync = true
          yield
        ensure
          stream.reopen(old_stream)
          old_stream.close
        end

        def quietly
          silence_stream(STDOUT) do
            silence_stream(STDERR) do
              yield
            end
          end
        end

        def capture(stream)
          stream = stream.to_s
          captured_stream = Tempfile.new(stream)
          stream_io = eval("$#{stream}") # rubocop:disable Lint/Eval
          origin_stream = stream_io.dup
          stream_io.reopen(captured_stream)

          yield

          stream_io.rewind
          return captured_stream.read
        ensure
          captured_stream.close
          captured_stream.unlink
          stream_io.reopen(origin_stream)
        end
      end
    end
  end
end


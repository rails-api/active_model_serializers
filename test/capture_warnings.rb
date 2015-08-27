# https://raw.githubusercontent.com/metric_fu/metric_fu/master/spec/capture_warnings.rb
require 'tempfile'
require 'fileutils'

class CaptureWarnings
  def initialize(fail_on_warnings = true)
    @fail_on_warnings = fail_on_warnings
    @stderr_file = Tempfile.new('app.stderr')
    @app_root ||= Dir.pwd
    @output_dir = File.join(app_root, 'tmp')
    FileUtils.mkdir_p(output_dir)
    @bundle_dir = File.join(app_root, 'bundle')
    @output = STDOUT
  end

  def execute!
    $VERBOSE = true
    $stderr.reopen(stderr_file.path)

    Minitest.after_run do
      stderr_file.rewind
      lines = stderr_file.read.split("\n")
      stderr_file.close!
      $stderr.reopen(STDERR)
      after_tests(lines)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def after_tests(lines)
    app_warnings, other_warnings = lines.partition { |line|
      line.include?(app_root) && !line.include?(bundle_dir)
    }

    header = "#{'-' * 22} app warnings: #{'-' * 22}"
    output.puts
    output.puts header

    if app_warnings.any?
      output.puts app_warnings.join("\n")
    else
      output.puts 'None. Yay!'
    end

    if other_warnings.any?
      File.write(File.join(output_dir, 'warnings.txt'), other_warnings.join("\n") << "\n")
      output.puts
      output.puts 'Non-app warnings written to tmp/warnings.txt'
      output.puts
    end

    output.puts
    output.puts '-' * header.size

    # fail the build...
    if fail_on_warnings && app_warnings.any?
      abort "Failing build due to app warnings: #{app_warnings.inspect}"
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  attr_reader :stderr_file, :app_root, :output_dir, :bundle_dir, :fail_on_warnings, :output
end

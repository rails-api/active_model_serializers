# https://raw.githubusercontent.com/metric_fu/metric_fu/master/spec/capture_warnings.rb
require "tempfile"
require "fileutils"

class CaptureWarnings
  def initialize(fail_on_warnings = true)
    @fail_on_warnings = fail_on_warnings
    @stderr_file = Tempfile.new("app.stderr")
    @app_root ||= Dir.pwd
    @output_dir = File.join(app_root, "tmp")
    FileUtils.mkdir_p(output_dir)
    @bundle_dir = File.join(app_root, "bundle")
  end

  def before_tests
    $stderr.reopen(stderr_file.path)
    $VERBOSE = true
    at_exit { $stderr.reopen(STDERR) }
  end

  def after_tests
    stderr_file.rewind
    lines = stderr_file.read.split("\n")
    stderr_file.close!

    $stderr.reopen(STDERR)

    app_warnings, other_warnings = lines.partition { |line|
      line.include?(app_root) && !line.include?(bundle_dir)
    }

    if app_warnings.any?
      puts <<-WARNINGS
#{'-' * 30} app warnings: #{'-' * 30}

#{app_warnings.join("\n")}

#{'-' * 75}
      WARNINGS
    end

    if other_warnings.any?
      File.write(File.join(output_dir, "warnings.txt"), other_warnings.join("\n") << "\n")
      puts
      puts "Non-app warnings written to tmp/warnings.txt"
      puts
    end

    # fail the build...
    if fail_on_warnings && app_warnings.any?
      abort "Failing build due to app warnings: #{app_warnings.inspect}"
    end
  end

  private
  attr_reader :stderr_file, :app_root, :output_dir, :bundle_dir, :fail_on_warnings
end

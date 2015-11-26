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
    @ignore_dirs = [
      File.join(app_root, '.bundle'),
      File.join(app_root, 'bundle'),
      File.join(app_root, 'vendor')
    ]
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

  def after_tests(lines)
    app_warnings, other_warnings = lines.partition do |line|
      line.include?(app_root) && ignore_dirs.none? { |ignore_dir| line.include?(ignore_dir) }
    end

    if app_warnings.any?
      warnings_message = app_warnings.join("\n")
      print_warnings = true
    else
      warnings_message = 'None. Yay!'
      ENV['FULL_BUILD'] ||= ENV['CI']
      running_ci          = ENV['FULL_BUILD'] =~ /\Atrue\z/i
      print_warnings = running_ci
    end

    if other_warnings.any?
      File.write(File.join(output_dir, 'warnings.txt'), other_warnings.join("\n") << "\n")
      warnings_message << "\nNon-app warnings written to tmp/warnings.txt"
      print_warnings = true
    end

    header = "#{'-' * 22} app warnings: #{'-' * 22}"
    message = <<-EOF.strip_heredoc

    #{header}

    #{warnings_message}

    #{'-' * header.size}
    EOF

    output.puts(message) if print_warnings

    # fail the build...
    if fail_on_warnings && app_warnings.any?
      abort "Failing build due to app warnings: #{app_warnings.inspect}"
    end
  end

  private

  attr_reader :stderr_file, :app_root, :output_dir, :ignore_dirs, :fail_on_warnings, :output
end

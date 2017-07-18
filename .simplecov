# https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config
# see https://github.com/colszowka/simplecov/blob/master/lib/simplecov/defaults.rb
# vim: set ft=ruby

ENV['FULL_BUILD'] ||= ENV['CI']

## CONFIGURE SIMPLECOV
SimpleCov.profiles.define 'app' do
  coverage_dir 'coverage'
  load_profile 'test_frameworks'

  add_group 'Libraries', 'lib'

  add_group 'Long files' do |src_file|
    src_file.lines.count > 100
  end
  class MaxLinesFilter < SimpleCov::Filter
    def matches?(source_file)
      source_file.lines.count < filter_argument
    end
  end
  add_group 'Short files', MaxLinesFilter.new(5)

  # Exclude these paths from analysis
  add_filter '/config/'
  add_filter '/db/'
  add_filter 'tasks'
  add_filter '/.bundle/'
end

generate_report = !!(ENV['COVERAGE'] =~ /\Atrue\z/i)
running_ci = !!(ENV['FULL_BUILD'] =~ /\Atrue\z/i)
generate_result = running_ci || generate_report
require_relative 'scripts/coverage_report'
reporter = CoverageReport.new
if generate_report
  reporter.configure_to_generate_report!
  SimpleCov.at_exit do
    reporter.generate_report!
  end
end
if generate_result
  # only start when generating a result
  SimpleCov.start 'app'
  STDERR.puts '[COVERAGE] Running'
  reporter.configure_to_generate_result!
end
SimpleCov.formatters = reporter.formatters

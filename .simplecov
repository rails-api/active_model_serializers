# https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config
# see https://github.com/colszowka/simplecov/blob/master/lib/simplecov/defaults.rb
# vim: set ft=ruby

## DEFINE VARIABLES
@minimum_coverage = 100.0
ENV['FULL_BUILD'] ||= ENV['CI']
@running_ci       = !!(ENV['FULL_BUILD'] =~ /\Atrue\z/i)
@generate_report  = @running_ci || !!(ENV['COVERAGE'] =~ /\Atrue\z/i)
@output = STDOUT
# rubocop:enable Style/DoubleNegation

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

if @generate_report
  SimpleCov.start 'app'
  if @running_ci
    require 'codeclimate-test-reporter'
    @output.puts '[COVERAGE] Running with SimpleCov Simple Formatter and CodeClimate Test Reporter'
    formatters = [
      SimpleCov::Formatter::SimpleFormatter,
      CodeClimate::TestReporter::Formatter
    ]
  else
    @output.puts '[COVERAGE] Running with SimpleCov HTML Formatter'
    formatters = [SimpleCov::Formatter::HTMLFormatter]
  end
  SimpleCov.formatters = formatters
end

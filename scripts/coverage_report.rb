#!/usr/bin/env ruby

require 'json'
class CoverageReport
  attr_reader :formatters

  def initialize
    @formatters = []
  end

  def configure_to_generate_result!
    SimpleCov.configure do
      # use_merging   true
      minimum_coverage 0.0 # disable
      maximum_coverage_drop 100.0 # disable
    end
    SimpleCov.at_exit do
      STDERR.puts "[COVERAGE] creating #{File.join(SimpleCov.coverage_dir, '.resultset.json')}"
      SimpleCov.result.format!
    end
  end

  def configure_to_generate_report!
    @minimum_coverage = ENV.fetch('COVERAGE_MINIMUM') { 100.0 }.to_f.round(2)
    SimpleCov.configure do
      minimum_coverage @minimum_coverage
      # minimum_coverage_by_file 60
      # maximum_coverage_drop 1
      refuse_coverage_drop
    end

    @formatters = [SimpleCov::Formatter::HTMLFormatter]
  end

  def generate_report!
    report_dir = SimpleCov.coverage_dir
    file = File.join(report_dir, '.resultset.json')
    if File.exist?(file)
      json = JSON.parse(File.read(file))
      result = SimpleCov::Result.from_hash(json)
      results = [result]
      merged_result = SimpleCov::ResultMerger.merge_results(*results)
      merged_result.format!
      STDERR.puts "[COVERAGE] merged #{file}; processing..."
      process_result(merged_result)
    else
      abort "No files found to report: #{Dir.glob(report_dir)}"
    end
  end

  # https://github.com/colszowka/simplecov/blob/v0.14.1/lib/simplecov/defaults.rb#L71-L98
  def process_result(result)
    @exit_status = SimpleCov::ExitCodes::SUCCESS
    covered_percent = result.covered_percent.round(2)
    covered_percentages = result.covered_percentages.map { |p| p.round(2) }

    if @exit_status == SimpleCov::ExitCodes::SUCCESS # No other errors
      if covered_percent < SimpleCov.minimum_coverage # rubocop:disable Metrics/BlockNesting
        $stderr.printf("Coverage (%.2f%%) is below the expected minimum coverage (%.2f%%).\n", covered_percent, SimpleCov.minimum_coverage)
        @exit_status = SimpleCov::ExitCodes::MINIMUM_COVERAGE
      elsif covered_percentages.any? { |p| p < SimpleCov.minimum_coverage_by_file } # rubocop:disable Metrics/BlockNesting
        $stderr.printf("File (%s) is only (%.2f%%) covered. This is below the expected minimum coverage per file of (%.2f%%).\n", result.least_covered_file, covered_percentages.min, SimpleCov.minimum_coverage_by_file)
        @exit_status = SimpleCov::ExitCodes::MINIMUM_COVERAGE
      elsif (last_run = SimpleCov::LastRun.read) # rubocop:disable Metrics/BlockNesting
        coverage_diff = last_run["result"]["covered_percent"] - covered_percent
        if coverage_diff > SimpleCov.maximum_coverage_drop # rubocop:disable Metrics/BlockNesting
          $stderr.printf("Coverage has dropped by %.2f%% since the last time (maximum allowed: %.2f%%).\n", coverage_diff, SimpleCov.maximum_coverage_drop)
          @exit_status = SimpleCov::ExitCodes::MAXIMUM_COVERAGE_DROP
        end
      end
    end

    # Don't overwrite last_run file if refuse_coverage_drop option is enabled and the coverage has dropped
    unless @exit_status == SimpleCov::ExitCodes::MAXIMUM_COVERAGE_DROP
      SimpleCov::LastRun.write(:result => {:covered_percent => covered_percent})
    end

    # Force exit with stored status (see github issue #5)
    # unless it's nil or 0 (see github issue #281)
    Kernel.exit @exit_status if @exit_status && @exit_status > 0
  end
end
if __FILE__ == $0
  require 'simplecov'
  reporter = CoverageReport.new
  reporter.configure_to_generate_report!
  reporter.generate_report!
end

# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |config|
    config.report_with_single_file = true
    config.lcov_file_name = "solidus-weighted-shipping.lcov"
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])

  SimpleCov.enable_coverage :branch
  SimpleCov.start("rails") do
    track_files "{app,lib}/**/*.{rb,rake}"
    add_filter %r{^/lib/.*/version.rb}
    add_group "Domain", "lib/solidus_weighted_shipping"
    add_group "Solidus adapter", "app/models/spree/calculator/shipping"

    minimum_coverage line: 95, branch: 85
    minimum_coverage_by_file 70
  end
end

require "solidus_weighted_shipping/domain"
require_relative "support/domain_helpers"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.order = :random
  config.fail_if_no_examples = true
  config.before(:suite) do
    if ENV["CI"] && RSpec.world.all_examples.any? { |example| example.metadata[:focus] }
      raise "Remove focused examples before running CI"
    end
  end
  Kernel.srand config.seed
  config.include DomainSpecHelpers
end

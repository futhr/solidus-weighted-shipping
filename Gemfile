# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

if ENV["SOLIDUS_BRANCH"]
  gem "solidus", github: "solidusio/solidus", branch: ENV.fetch("SOLIDUS_BRANCH")
else
  gem "solidus", "~> #{ENV.fetch("SOLIDUS_VERSION", "4.7")}.0"
end

rails_version = ENV.fetch("RAILS_VERSION", "8.1")
rails_gem_version = Gem::Version.new(rails_version)
rails_minor = rails_gem_version.segments.first(2).join(".")
gem "rails", "~> #{rails_minor}.0"
gem "sqlite3", "~> 2.0"

gem "csv" if Gem.ruby_version >= Gem::Version.new("3.4")

gemspec

group :development, :test do
  gem "solidus_dev_support", "~> 2.12"
  gem "bundler-audit", "~> 0.9"
  gem "faraday-retry", "~> 2.4"
  gem "mutant-rspec", "~> 0.16.3"
  gem "rantly", "~> 3.0"
  gem "rspec", "~> 3.13"
  gem "simplecov-lcov", "~> 0.9"
  gem "standard", "~> 1.56"
end

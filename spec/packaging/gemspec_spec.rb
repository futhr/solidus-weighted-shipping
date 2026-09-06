# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "open3"
require "rubygems/package"

RSpec.describe "the packaged gem" do
  subject(:specification) do
    Gem::Specification.load(File.expand_path("../../solidus_weighted_shipping.gemspec", __dir__))
  end

  it "publishes the canonical weighted-shipping identity" do
    expect(specification.name).to eq("solidus_weighted_shipping")
    expect(specification.version.to_s).to eq(SolidusWeightedShipping::VERSION)
    expect(specification.homepage).to eq("https://github.com/futhr/solidus-weighted-shipping")
    expect(specification.metadata["source_code_uri"]).to end_with("/tree/main")
    expect(specification.metadata["documentation_uri"]).to end_with("/blob/main/docs/README.md")
    expect(specification.metadata).to include(
      "allowed_push_host" => "https://rubygems.org",
      "rubygems_mfa_required" => "true"
    )
  end

  it "contains runtime code and documentation without test or generated files" do
    expect(specification.files).to include(
      "lib/solidus_weighted_shipping.rb",
      "lib/solidus_weighted_shipping/domain.rb",
      "app/models/spree/calculator/shipping/weighted_shipping.rb",
      "README.md",
      "CONTRIBUTING.md",
      "SECURITY.md",
      "docs/README.md",
      "docs/architecture.md",
      "docs/migration.md",
      "docs/release.md",
      "docs/security.md",
      "docs/testing.md",
      "docs/troubleshooting.md"
    )
    expect(specification.files.grep(/spree_postal_service/)).to be_empty
    expect(specification.files).not_to include("spree_postal_service.gemspec")
    expect(specification.files.grep(%r{\A(?:spec|sandbox|tmp)/})).to be_empty
  end

  it "builds and loads the packaged domain from a source archive without Git" do
    project_root = File.expand_path("../..", __dir__)
    Dir.mktmpdir("weighted-shipping-package") do |directory|
      specification.files.each do |file|
        destination = File.join(directory, file)
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(File.join(project_root, file), destination)
      end

      output, status = Open3.capture2e(
        Gem.ruby, "-S", "gem", "build", "solidus_weighted_shipping.gemspec", "--strict",
        chdir: directory
      )
      expect(status.success?).to be(true), output

      artifact = Gem::Package.new(File.join(directory, "solidus_weighted_shipping-#{specification.version}.gem"))
      expect(artifact.contents.sort).to eq(specification.files.sort)
      installed = File.join(directory, "installed")
      artifact.extract_files(installed)

      # Avoid Bundler and the checkout's load path when requiring the artifact.
      output, status = Open3.capture2e(
        {"RUBYOPT" => nil, "RUBYLIB" => nil, "BUNDLE_GEMFILE" => nil},
        Gem.ruby, "-I#{installed}/lib", "-e",
        'require "solidus_weighted_shipping/domain"; abort unless SolidusWeightedShipping::RateTable.parse("1: 2").price_for("1") == 2',
        chdir: directory
      )
      expect(status.success?).to be(true), output
    end
  end

  it "declares only the narrow runtime dependencies" do
    dependencies = specification.runtime_dependencies.to_h { |dependency| [dependency.name, dependency.requirement.to_s] }

    expect(dependencies).to eq(
      "bigdecimal" => ">= 3.1, < 5",
      "solidus_core" => ">= 4.6.2, < 5",
      "solidus_support" => ">= 0.12, < 1"
    )
  end
end

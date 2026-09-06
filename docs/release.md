# Release guide

The package is `solidus_weighted_shipping`. This checkout remains a
`4.0.0.pre` candidate. The preparation commands below build and test it locally;
they do not tag, push, or publish.

## Local preparation

```sh
bin/setup
bin/sandbox
bin/rake quality:coverage
bin/rake quality:lint
bin/rake quality:mutation
bundle exec bundle-audit check --update
actionlint .github/workflows/*.yml
mkdir -p pkg
gem build solidus_weighted_shipping.gemspec --strict
```

Run all rows in the [compatibility matrix](testing.md#supported-matrix) with
separate dependency resolutions. Inspect the eight browser screenshots.
The [audit report](final-audit.md) records the results for this candidate.

Build the artifact under `pkg` when retaining it for review:

```sh
gem build solidus_weighted_shipping.gemspec --strict \
  --output pkg/solidus_weighted_shipping-4.0.0.pre.gem
gem specification pkg/solidus_weighted_shipping-4.0.0.pre.gem
shasum -a 256 pkg/solidus_weighted_shipping-4.0.0.pre.gem
```

The file list includes runtime code, locales, Markdown docs, the gemspec, and
top-level contributor/security/license files. It excludes tests, the generated
app, screenshots, coverage, and local configuration. Packaging specs verify
building without Git and loading the extracted domain outside the checkout.
Direct runtime dependencies are `bigdecimal`, `solidus_core`, and
`solidus_support`.

The gemspec declares MFA required and limits pushes to RubyGems.org. These
fields do not establish RubyGems ownership or configure a Trusted Publisher.

## Maintainer setup before publication

1. Verify RubyGems ownership or availability of `solidus_weighted_shipping`
   and enable MFA on the releasing account. A 404 response does not reserve a
   name. Do not publish this code under `spree_postal_service`.
2. Configure a pending RubyGems Trusted Publisher for GitHub owner `futhr`,
   repository `solidus-weighted-shipping`, workflow `release.yml`, and
   environment `release`.
3. Create a GitHub environment named `release` with the intended approval and
   tag restrictions. Verify branch protection and immutable release-tag rules.
   Repository visibility is a manual, user-only setting and must not be changed
   by an automated preparation or release task.
4. Review the two development-only Puma exceptions in [SECURITY.md](../SECURITY.md).
5. Choose the stable version, change `SolidusWeightedShipping::VERSION`,
   move the unreleased changelog entries into a dated version heading, and
   update the README badge and installation instructions.

See [RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/releasing-gems/)
for the account setup. No long-lived RubyGems API token is needed.

## Future publication

After the stable version commit is reviewed and its required checks pass:

1. Create an annotated version tag on that exact commit and push it.
2. The tag workflow runs the shared CI matrix, quality, mutation, and packaging
   jobs. Publication also checks that the tag matches a stable gem version and
   that the commit belongs to `main`, then audits the publishing bundle.
3. After the `release` environment approval, the workflow publishes through
   RubyGems Trusted Publishing and retains the gem plus its SHA-256 checksum.
4. Compare the downloaded RubyGems artifact with that checksum. Create the
   GitHub release from the existing tag and attach the retained artifact.

Do not move a published tag. `rake release` is a publishing command; do not use
it for a local readiness check. A failed release should be investigated before
retrying, including whether RubyGems already accepted the version.

# Testing

Use Ruby 3.3 or newer, Bundler, SQLite, and Chrome/Chromium. The test application
is generated under `spec/dummy` and ignored by Git.

## Run the checks

```sh
bin/setup
bin/sandbox
bin/rake quality:coverage
bin/rake quality:lint
bin/rake quality:mutation
bundle exec bundle-audit check --update
actionlint .github/workflows/*.yml
```

`bin/sandbox` deletes and rebuilds the generated application. Use it after
changing Rails or Solidus versions. `bin/rake` runs the full suite without
coverage reporting. For a focused change, run a spec directly:

```sh
bundle exec rspec spec/solidus_weighted_shipping/rate_table_spec.rb
```

## What the suite covers

- Unit specs cover parsing, exact decimals, weight boundaries, overflow rates,
  item constraints, handling, free shipping, and immutable quote values.
- Rantly properties generate weights, dimensions, quantities, and rate tables
  to check conservation, orientation, and monotonicity where applicable.
- Solidus specs use persisted records and the stock estimator to check package
  scope, preference changes, currency amounts, migration, and absence of writes
  during estimation and migration dry runs.
- Browser specs exercise the real admin and a test-only estimate page.
  The generated app has no storefront; the estimate page calls the real
  estimator but is not a checkout implementation.
- Packaging specs build a gem from an archive without `.git`, inspect its file
  list, and load the extracted domain outside the checkout.

CI rejects focused examples and empty suites. RSpec prints its random seed;
use `--seed <number>` to reproduce a failure.

## Coverage and mutation checks

`COVERAGE=true` enables SimpleCov with minimums of 95% line coverage, 85% branch
coverage, and 70% per source file. Runtime Ruby and rake files are tracked even
when not loaded. Other test runs leave coverage reports alone.

Mutant checks `RateTable#price_for`, `Calculator#quote`,
`Calculator#handling_for`, and `Constraints#eligibility_for`. The selected
mutations must all be killed. This is targeted evidence, not mutation coverage
of the entire library. CI uses Ruby 3.3 to match the parser grammar.
The command also passes on Ruby 4.0 with a parser compatibility warning.

The quality job saves HTML and LCOV coverage. Codecov uploads are optional:
configure the repository in Codecov, add the `CODECOV_TOKEN` repository secret,
and set the repository variable `CODECOV_ENABLED=true`. Uploads are skipped for
fork pull requests and release tags. RubyGems publication uses OIDC separately.

## Supported matrix

| Ruby | Rails | Solidus |
| --- | --- | --- |
| 3.3 | 7.2 | 4.6 |
| 3.4 | 7.2 | 4.6 |
| 3.4 | 7.2 | 4.7 |
| 3.4 | 8.0 | 4.7 |
| 4.0 | 8.1 | 4.7 |

Each row resolves published gems within the requested minor versions and runs
the suite without browser specs, followed by a dependency audit. The quality
job runs the full suite on Ruby 4.0/Rails 8.1/Solidus 4.7. Solidus `main` is
tested separately as an informational job. The release workflow reuses CI.

Ruby 3.2 and Rails 7.0 are no longer supported by this extension.
See [Ruby maintenance branches](https://www.ruby-lang.org/en/downloads/branches/)
and the [Rails maintenance policy](https://guides.rubyonrails.org/maintenance_policy.html).

Use a separate checkout for each dependency resolution. For example:

```sh
export SOLIDUS_VERSION=4.6 RAILS_VERSION=7.2
bundle install
bin/sandbox
bin/rake extension:specs SPEC_OPTS="--exclude-pattern spec/system/**/*_spec.rb"
```

`SOLIDUS_VERSION` selects published releases. Set `SOLIDUS_BRANCH=main` only
when testing upstream development code. The default is Solidus 4.7 with Rails
8.1. Lockfiles are local and ignored; update them when switching rows.

## Browser artifacts

The suite writes eight images under `tmp/screenshots`: admin configuration,
normal and threshold rates, an oversized package, free shipping, two packages,
a completed order, and invalid configuration. All data comes from test
factories. CI retains images for 14 days. Inspect them when changing admin
behavior and before release; assertions check behavior, not page layout.

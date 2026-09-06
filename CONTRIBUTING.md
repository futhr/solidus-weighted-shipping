# Contributing

Bug reports are most useful with a small rate table, the package's quantities
and weights, the expected price, and the Ruby/Rails/Solidus versions involved.
Use generated data rather than real customer orders.

## Set up the project

```sh
bin/setup
bin/sandbox
bin/rake
```

Use Ruby 3.3 or newer. The default bundle uses published Solidus 4.7 and Rails
8.1. `bin/sandbox` rebuilds the disposable app under `spec/dummy`; do not put
work you need to keep there. Install Chrome/Chromium for browser specs.

## Verify a change

Run the relevant specs while developing, then check coverage, style, mutation
tests, and dependencies:

```sh
bin/rake quality:coverage
bin/rake quality:lint
bin/rake quality:mutation
bundle exec bundle-audit check --update
```

Pricing changes need examples at and just above their boundaries. Include
failure cases and use decimal strings or `BigDecimal`, not Float literals.
Inspect the screenshots in `tmp/screenshots` when admin behavior changes.

## Reproduce a compatibility row

Use a separate checkout and keep the same version variables throughout:

```sh
export SOLIDUS_VERSION=4.6 RAILS_VERSION=7.2
bundle install
bin/sandbox
bin/rake extension:specs SPEC_OPTS="--exclude-pattern spec/system/**/*_spec.rb"
```

See the [matrix and test guide](docs/testing.md#supported-matrix).
`SOLIDUS_BRANCH=main` selects upstream development code instead of a published
release. The local lockfile is ignored; update it when switching versions.

## Keep changes reviewable

Keep commits focused on one change and its regression tests. Update the
changelog and relevant documentation when behavior or support changes.
Use Conventional Commit subjects such as `fix:`, `test:`, or `docs:`.

Do not commit generated apps, coverage, packaged gems, screenshots, or local
lockfiles. Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md).

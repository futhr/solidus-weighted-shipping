# Security and reliability

The calculator validates merchant settings and product/package values before
returning an estimate. Invalid configuration is reported by model validation;
estimation omits the method when it cannot produce a valid quote.
`quote_package` exposes errors for diagnosis.

## Runtime behavior

Numbers must be finite and exactly representable as decimals. Tables are
limited to 1,000 bands, checked before constructing band values. Lookup uses
binary search and overflow is calculated by division. Input text and numeric
magnitudes have no separate byte-size limit; host apps should enforce their
normal request and configuration limits.

Rating reads prices, quantities, weights, dimensions, merchandise totals, and
currency. It does not read customer names, addresses, payment data, or secrets.
There are no runtime HTTP calls, controller actions, database tables, or
estimate writes. Solidus supplies admin authorization and shipping method
persistence. SQL notification tests check the absence of data writes during
estimation and migration dry runs.

The test preview controller is under `spec/support` and excluded from the gem.
It has no production authorization and must not be copied into a storefront.

## Dependencies and CI

Runtime dependencies are `bigdecimal`, `solidus_core`, and `solidus_support`.
Development tools live in the Gemfile. CI and the weekly security workflow
run Bundler Audit against the current advisory database. GitHub dependency
review runs on pull requests where the repository's plan supports that feature.
There is no Dependabot configuration in this repository.

GitHub Actions are pinned to commit SHAs. RubyGems metadata restricts the push
host to RubyGems.org and declares MFA required. The release workflow waits for
compatibility, coverage, style, mutation, and packaging checks, then audits its
own dependency resolution before requesting publication credentials.

Two Puma advisories remain excluded in the development bundle because
`solidus_dev_support` 2.12 requires Puma below 7. The affected PROXY protocol is
not enabled by the test server. [SECURITY.md](../SECURITY.md) records the exact
exceptions and removal conditions. They do not apply to a store's production
dependency audit.

## Reporting

Follow [SECURITY.md](../SECURITY.md) to report vulnerabilities privately.
Publication ownership, MFA, and protected GitHub environments are external
settings that maintainers must verify before releasing.

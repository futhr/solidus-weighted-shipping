# Solidus Weighted Shipping

[![CI](https://github.com/futhr/solidus-weighted-shipping/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/futhr/solidus-weighted-shipping/actions/workflows/ci.yml)
[![Codecov](https://codecov.io/github/futhr/solidus-weighted-shipping/branch/main/graph/badge.svg)](https://app.codecov.io/github/futhr/solidus-weighted-shipping)
[![Release candidate](https://img.shields.io/badge/release-4.0.0.pre-orange.svg)](CHANGELOG.md#unreleased)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D_3.3-CC342D.svg?logo=ruby&logoColor=white)](solidus_weighted_shipping.gemspec)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE.md)

Solidus Weighted Shipping calculates rates from weight bands you define.
It prices each Solidus package locally, without
carrier accounts or network calls.

It supports:

- weight-band rates and overflow parcels
- per-item weight and dimension limits
- a fallback for missing product weights
- package-level handling fees
- order-level free shipping
- validated, exact-decimal configuration

## Requirements

Ruby 3.3 or newer and Solidus 4.6.2 or 4.7 are supported. See the
[tested compatibility matrix](docs/testing.md#supported-matrix) for the exact
Ruby and Rails combinations.

## Installation

This checkout is versioned `4.0.0.pre`. To use it before the first stable
release, add the GitHub repository to your
`Gemfile`:

```ruby
gem "solidus_weighted_shipping",
  github: "futhr/solidus-weighted-shipping",
  branch: "main"
```

After `4.0.0` is published, use the normal RubyGems dependency:

```ruby
gem "solidus_weighted_shipping", "~> 4.0"
```

Run `bundle install`, then choose **Weighted Shipping** as the base calculator
for a shipping method in Solidus admin.

## Configuration

Enter one `maximum weight: price` band per line. Weights use the store's product
weight unit and prices use the order currency:

```text
1: 6
2: 9
5: 12
10: 15
20: 18
```

The calculator also exposes item limits, handling rules, a free-shipping
threshold, and a default item weight. Invalid configuration disables the rate
instead of guessing a checkout price. The [logic reference](docs/README.md#rating-logic)
documents every boundary and scope.

## Migrating from `spree_postal_service`

The gem and calculator have new names. Stop application processes, replace the
old dependency, then preview the database conversion from the new bundle:

```sh
DRY_RUN=1 bin/rake solidus_weighted_shipping:preferences:migrate
```

Follow the [migration guide](docs/migration.md) for the required deployment
order and rollback plan.

## Development

```sh
bin/setup
bin/sandbox
bin/rake
bin/rake quality:coverage
bin/rake quality:lint
bin/rake quality:mutation
```

Start with the [configuration guide](docs/README.md). Changes are welcome
through [CONTRIBUTING.md](CONTRIBUTING.md); security reports belong in
[SECURITY.md](SECURITY.md).

## License

Solidus Weighted Shipping is available under the
[BSD 3-Clause License](LICENSE.md).

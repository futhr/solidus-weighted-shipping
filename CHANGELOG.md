# Changelog

All notable changes to Solidus Weighted Shipping are recorded here.

The changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Historical releases were cut from version-specific Spree stable branches, not
one linear release branch. Their entries were reconstructed from the preserved
tags, tagged-tree diffs, and original GitHub release notes.

## Historical Spree branch archive

The last historical development breakpoint before the Solidus refactor and the
final state of every former Spree stable branch are preserved by `spree-*`
tags. Release tags identify published gem versions; archive tags identify exact
branch tips. This distinction matters for the 1.1, 1.2, and 1.3 lines, whose
final maintenance commits were made after their last release tags.

| Former branch | Preserved tag | Final commit | Release / compatibility |
| --- | --- | --- | --- |
| `1-1-stable` | [`spree-1-1-stable`][spree-1-1-stable] | [`6ab80f6`][6ab80f6] | [1.1.2] |
| `1-2-stable` | [`spree-1-2-stable`][spree-1-2-stable] | [`130d803`][130d803] | [1.2.0] |
| `1-3-stable` | [`spree-1-3-stable`][spree-1-3-stable] | [`f01a42c`][f01a42c] | [1.3.0] |
| `2-0-stable` | [`spree-2-0-stable`][spree-2-0-stable] | [`5dbdc07`][5dbdc07] | [2.0.1] |
| `2-1-stable` | [`spree-2-1-stable`][spree-2-1-stable] | [`60cd0d4`][60cd0d4] | [2.1.0] |
| `2-2-stable` | [`spree-2-2-stable`][spree-2-2-stable] | [`604f2e3`][604f2e3] | [2.2.0] |
| `2-3-stable` | [`spree-2-3-stable`][spree-2-3-stable] | [`7987d01`][7987d01] | [2.3.1] |
| `2-4-stable` | [`spree-2-4-stable`][spree-2-4-stable] | [`b97661e`][b97661e] | [2.4.0] |
| `3-0-stable` | [`spree-3-0-stable`][spree-3-0-stable] | [`1600766`][1600766] | [3.0.0] |
| `3-1-stable` | [`spree-3-1-stable`][spree-3-1-stable] | [`82c7463`][82c7463] | [3.1.0] |
| `master` | [`spree-3-3-alpha`][spree-3-3-alpha] | [`b105df4`][b105df4] | `3.3.0.alpha` / Spree `>= 3.1, < 4` |

## [Unreleased]

Release candidate: `4.0.0.pre`.

### Breaking changes

- Rename the gem to `solidus_weighted_shipping` and the calculator to
  `Spree::Calculator::Shipping::WeightedShipping`. Existing stores must run
  the preference/STI migration before starting application processes.
- Require Ruby 3.3+ and Solidus 4.6.2 or 4.7. Test maintained Rails 7.2, 8.0,
  and 8.1 combinations; retire Ruby 3.2 and Rails 7.0.
- Calculate weight, item eligibility, and handling from the quoted package.
  Free shipping continues to use the whole order's merchandise total.
- Replace separate weight and price lists with a validated
  `maximum weight: price` table.

### Added

- Plain Ruby pricing objects with explicit rated, free, empty, and unavailable
  quotes; per-item dimensions and weight limits; fallback weight; handling fees;
  and a free-shipping threshold.
- Legacy preference migration with per-record transactions, failure reporting,
  and a dry run that issues no data writes.
- Boundary, property, mutation, Solidus integration, browser, and packaging
  tests, with coverage reports and optional Codecov uploads.
- Tag-triggered RubyGems Trusted Publishing after the shared CI checks.

### Fixed

- Reject malformed decimal preferences instead of allowing Solidus to convert
  them to zero or truncate rational values.
- Refresh cached policies after in-place rate-table edits.
- Return a zero quote for an empty Solidus package without accessing a missing
  order's currency.
- Preserve exact totals and prices when the host sets a BigDecimal precision
  limit.
- Reject contradictory quote states and boolean dimensions; copy mutable
  unavailable reasons so quote hashes remain stable.
- Remove conflicting serialized keys during migration and validate calculators
  that already use the new format.
- Build from source archives without requiring Git. Include contributor and
  security files referenced by the README.
- Reject focused examples in CI and keep mutation runs from overwriting
  coverage reports. Repair archive links in this changelog.

### Changed

- Use binary search for weight bands and reject excessive bands before
  normalizing their values.
- Resolve published Solidus versions by default. Development dependencies live
  in the Gemfile, and BigDecimal is an explicit runtime dependency.
- Replace repeated architecture diagrams and broad audit claims with concise
  behavior documentation, measured results, and current release prerequisites.

### Security

- Require patched Rails versions in the development matrix and audit every
  supported dependency resolution.
- Pin workflow actions to commit SHAs, require MFA in gem metadata, and restrict
  the push host to RubyGems.org.
- Retain two documented development-only Puma exceptions while
  `solidus_dev_support` requires Puma below 7. Production stores must audit
  their own bundles.

### Removed

- Legacy runtime aliases, the committed sandbox, old frontend code, and
  obsolete Travis, Guard, Hound, Reek, and FactoryGirl configuration.

## [3.1.0] - 2017-02-03

### Changed

- `feat(compat)`: add support for the Spree `3-1-stable` line and align the
  runtime and development dependencies with Spree 3.1.
- `chore(tooling)`: update RSpec, Sass, lint, and supported Ruby test versions.

### Fixed

- `fix(weight)`: retain the explicit `weight > 0` fallback check for the
  numeric values returned by supported Spree versions.

## [3.0.0] - 2017-02-03

### Changed

- `feat(compat)`: add support for the Spree `3-0-stable` line.
- `chore(ruby)`: require Ruby 2.1 or newer and test Ruby 2.2.5 and 2.3.1.
- `docs(contributing)`: expand the contributor and development guidance.

## [2.4.0] - 2014-11-28

### Changed

- `feat(compat)`: add support for the Spree `2-4-stable` line by backporting
  the maintained calculator from the development branch.
- `ci(travis)`: move the stable branch to the then-current Travis build
  environment.

## [2.3.1] - 2014-11-22

### Fixed

- `fix(weight)`: use the configured fallback when Spree returns a non-positive
  `BigDecimal` product weight instead of `nil`.

### Changed

- `chore(tooling)`: update lint rules and remove RuboCop from the interactive
  Guard loop where it conflicted with Pry.

## [2.3.0] - 2014-11-21

### Changed

- `feat(compat)`: add support for the Spree `2-3-stable` line.
- `refactor(calculator)`: reorganize the calculator into the Spree shipping
  namespace and split price, weight, index, and handling calculations into
  focused methods without intentionally changing merchant behavior.
- `test(harness)`: modernize RSpec support, database cleanup, factories,
  translation checks, and coverage tooling.
- `chore(quality)`: add the contemporary Hound, RuboCop, Reek, and development
  dependency configuration used by the project at that time.

## [2.2.0] - 2014-04-05

### Changed

- `feat(compat)`: add support for the Spree `2-2-stable` line; no calculator
  behavior change was required.

## [2.1.0] - 2014-04-05

### Changed

- `feat(compat)`: add support for Spree `2-1-stable` and Rails 4.
- `refactor(spree)`: move the class to
  `Spree::Calculator::Shipping::PostalService`, subclass
  `Spree::ShippingCalculator`, and consume package contents through the then-new
  shipping calculator API.
- `test(rspec)`: update the suite toward RSpec 3 syntax.

### Fixed

- `fix(dimensions)`: compare the second-longest side with the configured width
  limit instead of comparing the longest side twice.

## [2.0.1] - 2014-04-05

### Fixed

- `fix(i18n)`: move calculator translations under the Spree namespace and use
  `Spree.t` for Spree 2.0 admin labels.

## [2.0.0] - 2014-04-05

### Changed

- `feat(compat)`: add support for the Spree `2-0-stable` line.
- `test(harness)`: update Spree testing-support paths and dependencies for
  Spree 2.0.
- `chore(runtime)`: remove an unused URL helper dependency.

## [1.3.0] - 2014-04-05

### Changed

- `feat(compat)`: add support for the Spree `1-3-stable` line; no calculator
  behavior change was required.
- `docs(release)`: add RubyGems version information to the README.

## [1.2.0] - 2014-04-05

### Changed

- `feat(compat)`: add support for the Spree `1-2-stable` line; no calculator
  behavior change was required.
- `docs(install)`: switch installation guidance from a Git branch to the
  published gem.

## [1.1.2] - 2014-04-05

### Added

- `release(rubygems)`: publish the first recorded RubyGems release for
  `spree_postal_service`.

### Changed

- `ci(ruby)`: drop Ruby 1.8.7 from CI after dependency-resolution failures in
  its Nokogiri toolchain.

## [1.1.0] - 2014-04-05

Pre-release and first preserved tag.

### Added

- `feat(i18n)`: add Swedish translations and rename the Portuguese locale to
  the Rails-compatible `pt` key.
- `test(backport)`: add the full backported calculator and engine test suite.

### Changed

- `chore(maintenance)`: transfer active maintenance and clean up the engine,
  packaging, formatting, and documentation for Spree 1.1.

[Unreleased]: https://github.com/futhr/solidus-weighted-shipping/compare/v3.1.0...HEAD
[3.1.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v3.1.0
[3.0.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v3.0.0
[2.4.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.4.0
[2.3.1]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.3.1
[2.3.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.3.0
[2.2.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.2.0
[2.1.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.1.0
[2.0.1]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.0.1
[2.0.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v2.0.0
[1.3.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v1.3.0
[1.2.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v1.2.0
[1.1.2]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v1.1.2
[1.1.0]: https://github.com/futhr/solidus-weighted-shipping/releases/tag/v1.1.0
[spree-1-1-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-1-1-stable
[spree-1-2-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-1-2-stable
[spree-1-3-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-1-3-stable
[spree-2-0-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-2-0-stable
[spree-2-1-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-2-1-stable
[spree-2-2-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-2-2-stable
[spree-2-3-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-2-3-stable
[spree-2-4-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-2-4-stable
[spree-3-0-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-3-0-stable
[spree-3-1-stable]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-3-1-stable
[spree-3-3-alpha]: https://github.com/futhr/solidus-weighted-shipping/tree/spree-3-3-alpha
[6ab80f6]: https://github.com/futhr/solidus-weighted-shipping/commit/6ab80f669a3a9cbafe95dbc6135b49ab126c30e1
[130d803]: https://github.com/futhr/solidus-weighted-shipping/commit/130d8032287797749730e0099dcda28e92c6aa10
[f01a42c]: https://github.com/futhr/solidus-weighted-shipping/commit/f01a42c7a297564661ba853e402039ce8126e306
[5dbdc07]: https://github.com/futhr/solidus-weighted-shipping/commit/5dbdc07298ea2dbc849c34cded7ea364f172fd49
[60cd0d4]: https://github.com/futhr/solidus-weighted-shipping/commit/60cd0d40cf0b69126f76d5e257d03265dae1a245
[604f2e3]: https://github.com/futhr/solidus-weighted-shipping/commit/604f2e35ffd78813f1583c90fd979c97eccd4800
[7987d01]: https://github.com/futhr/solidus-weighted-shipping/commit/7987d01f1f14575a1701c1893d1f30c150127c85
[b97661e]: https://github.com/futhr/solidus-weighted-shipping/commit/b97661e0d02a7a740c6e5667e8110a107007c5e0
[1600766]: https://github.com/futhr/solidus-weighted-shipping/commit/16007666936a357800dcf7632244b6e6650d1fb7
[82c7463]: https://github.com/futhr/solidus-weighted-shipping/commit/82c7463a88ab3ef2f723136d2a9315f0bec4098a
[b105df4]: https://github.com/futhr/solidus-weighted-shipping/commit/b105df4515afc44659b2203a555367106d6cb3b8

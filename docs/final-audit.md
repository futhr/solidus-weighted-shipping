# Audit report

Reviewed on 6 September 2026, starting at commit `0750cfd`.

The candidate has been audited, corrected, tested, and prepared for a local
RubyGems build. It remains version `4.0.0.pre`. No tag, push, publication,
repository visibility change, or GitHub configuration change was performed.

## Findings addressed

| Finding | Impact and correction | Commit |
| --- | --- | --- |
| Decimal preferences were converted with Solidus's permissive `to_d`. | Invalid free-shipping thresholds could become zero, and rational fees could be truncated. Preserve bad input for validation and coerce valid decimals exactly. | `a1061f3` |
| Cached rate signatures shared mutable strings. | An in-place table edit could keep charging an old rate. Copy and freeze each signature value. | `4732027` |
| Empty Solidus packages have no order. | Quoting them raised while reading currency. Use the attached shipment's order currency or the configured default for a zero quote. | `53c9f5b` |
| Migration could leave two versions of a canonical key. | Remove old string and symbol forms before assigning the migrated value. | `174d1ce` |
| Dry runs wrote temporary STI updates; canonical rows skipped validation. | Make dry mode read-only, validate all matching calculators, and test failure isolation. | `d972961` |
| Band limits were checked after parsing every value. | Reject oversized tables earlier, reject invalid text encodings, and use binary search for lookup. | `3eaf41d` |
| Quotes allowed contradictory states and mutable reasons. | Validate weights, parcel counts, and fee totals; copy reason strings. Reject boolean dimensions. | `fce8bc9` |
| Host decimal limits rounded arithmetic. | Calculate at full precision and restore the host setting, including on exceptions. | `4d47375` |
| Development used an unreleased Solidus branch and obsolete matrix entries. | Default to published gems, update tools, require Ruby 3.3+, declare BigDecimal, and test maintained Rails lines. | `e1c13c1` |
| Packaging depended on Git and omitted linked documents. | Use an explicit file allowlist; test a strict build from a source archive and load the extracted domain. | `cdc5c4e` |
| Focused specs could pass CI; mutation runs rewrote coverage. | Reject focus/empty suites and enable coverage only for coverage runs. Respect custom test-app paths. | `fb1e119` |
| Passing compatibility tests hid vulnerable Rails resolutions. | Require patched Rails minimums and audit every matrix row. | `7359e9b` |
| Currency tests used integer prices for every currency. | Verify JPY whole units and KWD three-decimal amounts without implicit rounding. | `204f91d` |
| Docs repeated diagrams and overstated verification. | Explain actual boundaries, fix archive links, correct Codecov/Dependabot claims, and separate local preparation from publication. | `c7a0efa` |

The pricing boundaries were preserved: item limits and rate bands are inclusive;
free shipping requires an order total strictly above the threshold; handling
applies at or below its package threshold. Negative historical product weights
still use the fallback. Overflow remains a weight-based pricing rule, not a
physical packing algorithm.

## Verification

Tests were run locally on macOS/ARM64, with separate dependency resolutions.
These are local results; remote GitHub Actions checks have not been run for the
new commits because nothing was pushed.

| Ruby | Rails | Solidus | Result |
| --- | --- | --- | --- |
| 3.3.12 | 7.2.3.2 | 4.6.2 | 102 non-browser examples passed |
| 3.4.10 | 7.2.3.2 | 4.6.2 | 102 non-browser examples passed |
| 3.4.10 | 7.2.3.2 | 4.7.0 | 102 non-browser examples passed |
| 3.4.10 | 8.0.5.1 | 4.7.0 | 102 non-browser examples passed |
| 4.0.6 | 8.1.3.1 | 4.7.0 | 107 examples passed, including browser specs |

- Coverage: 99.28% of lines (549/553) and 96.82% of branches (213/220).
- Mutation: all 382 selected mutants killed, with no survivors or timeouts.
  Checked on Ruby 3.3 and 4.0; Ruby 4.0 emits a parser compatibility warning.
- StandardRB, Solidus RuboCop rules, actionlint, and markdownlint passed.
- An intentionally focused test was rejected with `CI=true`.
- The eight browser screenshots were inspected: expected rates and admin
  validation appeared correctly with generated data.
- The source-archive packaging test passed, including a strict gem build and
  domain load outside the checkout.
- Band-search microbenchmark: 10,000 lookups near the final band of a 1,000-band
  table took about 0.322 seconds with linear search and 0.0034 seconds with
  binary search. This measures lookup only, not complete checkout throughput.

Commands are in [testing.md](testing.md). Local logs and browser images remain
under `tmp/`; they are not part of the published package.

## Dependencies and advisories

The primary bundle uses Solidus 4.7.0, Rails 8.1.3.1, solidus_support 0.15.0,
solidus_dev_support 2.12.0, BigDecimal 4.1.2, Mutant 0.16.3, Rantly 3.0.0,
Standard 1.56.0, and Bundler Audit 0.9.3. The dependency graph was refreshed,
including Selenium and rubyzip.

Each supported bundle passed Bundler Audit with the existing two Puma
exceptions. The advisory database was updated to
`e7179ad21701894b75796c5ddd72e5fbfc446165` (5 September 2026).
This means no *unignored* advisories, not an exception-free bundle.
`solidus_dev_support` still constrains Puma below the patched versions.
See [SECURITY.md](../SECURITY.md) for the conditions and removal criteria.

Version and support checks used the published
[Solidus gem metadata](https://rubygems.org/gems/solidus_core),
[development-support metadata](https://rubygems.org/gems/solidus_dev_support),
[Ruby maintenance branches](https://www.ruby-lang.org/en/downloads/branches/),
and [Rails maintenance policy](https://guides.rubyonrails.org/maintenance_policy.html).
All existing action pins were checked against their upstream refs; no pin
update was needed.

## External release prerequisites

Read-only GitHub checks on the audit date showed:

- `main` is the default branch and is protected by active history and PR rules.
- No GitHub environments are configured, so the intended protected `release`
  environment still needs to be created.
- No release-tag ruleset is configured.
- Secret scanning and push protection are disabled. Enable them through the
  repository's normal maintainer process if desired.

RubyGems returned HTTP 404 for `solidus_weighted_shipping`. That does not
reserve the name or prove access to a pending Trusted Publisher. Maintainer
MFA and RubyGems publisher ownership still need account-side verification.

Before publishing, configure the release environment and tag protection,
verify Trusted Publishing, choose the stable version/date, and run the remote
checks on the final commit. Repository visibility is a user-only setting.
The [release guide](release.md) gives the remaining steps.

## Scope and limits

The audit covered runtime code, Solidus integration, migration, tests,
dependencies, workflows, package contents, and documentation. It does not
establish that every possible host customization is compatible. Solidus
`main`, other databases, and a real storefront checkout were not exercised
locally. Browser coverage uses the real admin and a test-only estimator page.

Tables are limited by band count, not by total text bytes or numeric magnitude.
Host applications should apply their normal request/configuration limits.
The library does not convert currencies or physical units, apply carrier
packing rules, or round amounts to currency minor units.

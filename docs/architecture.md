# Architecture

The Rails engine registers
`Spree::Calculator::Shipping::WeightedShipping` with Solidus. The adapter reads
preferences and package contents, delegates calculation to plain Ruby objects,
and returns a decimal amount to `Spree::Stock::Estimator`.

## Responsibilities

| Component | Responsibility |
| --- | --- |
| `Decimal` | Validates exact numeric inputs and isolates arithmetic from host precision limits. |
| `PackageInput` | Copies quantities, prices, weights, dimensions, order total, and currency. |
| `Constraints` | Checks each item's effective weight and two longest dimensions. |
| `RateTable` | Validates bands, finds an inclusive threshold, and prices overflow weight. |
| `Calculator` | Applies eligibility, free shipping, rates, and handling in order. |
| `Quote` | Validates and exposes an immutable result. |
| `LegacyPreferences` | Converts old preference keys without loading Rails. |

Load `solidus_weighted_shipping/domain` to use these classes without Rails.
The full entrypoint, `solidus_weighted_shipping`, also loads the engine.

## Solidus integration

Package values come from `Spree::Stock::Package#contents`. Only free shipping
uses the whole order's `item_total`. The adapter follows the
`Spree::ShippingCalculator#compute_package` contract and leaves shipment and
order updates to Solidus.

Parsed policies are cached on the calculator instance. The key copies each
effective preference's type and text, including mutable strings. Editing a
preference, replacing the preference hash, or reloading changed data causes
the next quote to use a new policy. Package values are read for every quote.

Decimal preference conversion is stricter than Solidus's default `String#to_d`:
bad input is retained for validation instead of silently becoming zero.
Validation also normalizes whitespace in valid rate tables.

Band lookup takes O(log(bands)) comparisons. Package checks and totals are
linear in item count. Overflow uses division, so computation does not loop
once per logical parcel. A cached policy avoids reparsing but still compares
preference text; that comparison can be linear in the table's text size.

## Migration

The task recognizes the old STI class name as stored data. It reads and locks
matching rows without loading the missing class. Write mode changes the type
and preferences in a transaction per calculator; failed rows roll back while
other valid rows can succeed. Dry mode validates an in-memory calculator and
issues no data writes. See the [migration guide](migration.md).

The extension adds no tables, routes, or production controllers. The controller
under `spec/support` is a browser-test fixture and is excluded from the gem.
No runtime path makes network requests or writes shipping estimates to the
database. Weight-based pricing blocks do not model physical box packing.

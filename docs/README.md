# Configuration and shipping rules

Weighted Shipping prices a `Spree::Stock::Package` using the calculator's saved
preferences. Solidus handles shipping zones, methods, stock locations, taxes,
and selection of the resulting rates.

## Preferences

| Preference | Default | Meaning |
| --- | ---: | --- |
| `rate_table` | See below | One `maximum weight: price` band per line. |
| `maximum_item_weight` | `18` | Maximum weight of one item. |
| `maximum_item_width` | `60` | Maximum second-longest side of one item. |
| `maximum_item_length` | `120` | Maximum longest side of one item. |
| `free_shipping_threshold` | `120` | Order merchandise total must exceed this to qualify. |
| `handling_threshold` | `50` | Handling applies at or below this package merchandise total. |
| `handling_fee` | `10` | Fee added once per package when handling applies. |
| `default_item_weight` | `1` | Weight used for an item with missing, zero, or negative weight. |

The default rate table is:

```text
1: 6
2: 9
5: 12
10: 15
20: 18
```

Tables accept 1–1,000 bands. Thresholds must be positive and strictly
increasing; prices, fees, and monetary thresholds must be non-negative.
Item limits and the fallback weight must be positive. Blank lines and
whitespace around values are ignored. Prices need not increase with weight;
check discount bands carefully if heavier packages should never cost less.

Use the same weight and dimension units as your product records. No unit
conversion takes place. Monetary values are amounts in the order currency:
`12.50` means 12.50 currency units. A calculator has one rate table and does not
convert prices between currencies. Stores needing different currency tariffs
must restrict separate shipping methods to the appropriate currencies.

## Rating logic

1. An empty package gets a zero quote.
2. Each item's weight and dimensions are checked. If any item exceeds a limit,
   the package is unavailable, even if the order qualifies for free shipping.
3. Item weight is multiplied by quantity and summed for the package.
4. Shipping is free if `order.item_total > free_shipping_threshold`.
5. Otherwise, total weight selects a rate. Handling is added when
   `package merchandise total <= handling_threshold`.

An item exactly at a physical limit is allowed. The longest side is compared
with `maximum_item_length` and the second-longest with `maximum_item_width`.
Rotation does not change eligibility. Missing dimensions count as zero;
negative or malformed dimensions are rejected.

Free shipping uses Solidus's order merchandise total, before order-level
adjustments. Handling uses only the quoted package's item prices and quantities.
Neither rule uses the final amount paid after promotions, shipping, and tax
adjustments. Product prices can themselves include tax, depending on the store.

A zero free-shipping threshold means every eligible order with a positive
merchandise total qualifies. At the default threshold, an order of exactly
`120` pays shipping; `120.01` qualifies. A package worth exactly `50` includes
the default handling fee.

### Weight bands and overflow

Each band includes its maximum. With the default table, weight `2` costs `9`,
while `2.01` costs `12`, before handling or free shipping.

Above the last band, each full block of maximum weight costs the last-band
price. A remainder uses its first matching band. Weight `45`, for example,
costs `18 + 18 + 12 = 48`, before handling.

These blocks are a pricing rule. They do not pack indivisible products into
boxes or create shipments. `parcel_count` reports those pricing blocks, not
the number of physical boxes needed to fulfill an order.

### Numeric input

Ruby callers may pass integers, decimal strings, `BigDecimal`, or terminating
`Rational` values. Floats, non-terminating rationals, malformed numbers, and
infinities are rejected. Arithmetic preserves full decimal precision even if
the host sets `BigDecimal.limit`; the setting is restored afterward.
The calculator does not round prices to a currency's minor unit.

## Ruby API

Rails applications load `solidus_weighted_shipping`. For pricing tools that
do not need Rails, load `solidus_weighted_shipping/domain`.

The Solidus calculator exposes `quote_package(package)` for inspecting results
and `available?(package)` and `compute_package(package)` for estimation.

| Quote status | Amount | Available | Meaning |
| --- | --- | --- | --- |
| `rated` | Rate plus handling | yes | Eligible package with a priced weight. |
| `free_shipping` | `0` | yes | Eligible order above the free threshold. |
| `empty` | `0` | yes | No package contents. |
| `unavailable` | `nil` | no | An item exceeded a limit; `reason` identifies it. |

Quotes and their values are immutable. Invalid configuration raises
`ConfigurationError`; invalid package input raises `InputError`.
`quote_package` exposes those errors for diagnosis. The Solidus estimation
methods catch them and return `false` or `nil`, so the method is omitted.
Calculator validation reports configuration errors in the admin.

An empty Solidus package has no order of its own. Its zero quote uses the
shipment order's currency when available, otherwise `Spree::Config.currency`.

## Further reading

- [Architecture](architecture.md)
- [Migration from spree_postal_service](migration.md)
- [Testing and compatibility](testing.md)
- [Troubleshooting](troubleshooting.md)
- [Security](security.md)
- [Release preparation](release.md)
- [Audit findings and verification](final-audit.md)

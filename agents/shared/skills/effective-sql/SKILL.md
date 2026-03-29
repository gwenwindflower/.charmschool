# Writing SQL

Write SQL as a clear pipeline of CTEs. Optimize early, name things precisely,
and make the final output easy to read and debug.

## Core Pattern

Use CTEs as the default structure for non-trivial queries.

Split them into:

* **import CTEs**: pull in the minimum data needed
* **transformation CTEs**: join, aggregate, filter, rank, and reshape
* **output CTE**: present the final schema cleanly

This separation improves readability, performance, iteration speed, and
debuggability.

## CTE Structure

### 1. Import CTEs

Import CTEs should do as much reduction as possible, as early as possible.

Rules:

* Select only needed columns
* Rename ambiguous source fields immediately
* Push filters down early
* Prefer early `inner join`s when they reduce row count
* Revisit import CTEs as the query evolves; tighten them continuously

Example:

```sql
with

customer_orders_raw as (

    select
        id as order_id,
        customer_id,
        amount_cents as total_amount_cents

    from orders
    where customer_id is not null

),

...
```

### 2. Transformation CTEs

Each transformation CTE should do one clear thing and be named for that step.

Good names:

* `join_customers_orders`
* `calculate_lifetime_value`
* `rank_top_customers`

Rules:

* Select only from import CTEs or prior transformation CTEs
* Do not reach back to base tables once the pipeline has started
* Prefer many small, explicit steps over one dense CTE
* Use the most efficient pattern for the target warehouse, not just a valid one

Think of import CTEs as typed inputs and transformation CTEs as pure functions.

### 3. Output CTE

The final CTE defines the exposed schema.

Rules:

* Make column names clean and stable
* Order columns intentionally
* Favor readability over cleverness
* Keep all business logic above this layer

End every query with:

```sql
select * from <final_cte>
```

Benefits:

* Makes the pipeline shape obvious
* Simplifies debugging by swapping in an earlier CTE
* Keeps query edits localized and git diffs clean

## Select-Clause Organization

For wide `select` lists, group columns by type and keep the order consistent.

Recommended order:

1. **ids**
2. **text**
3. **numerics**
4. **booleans**
5. **dates**
6. **timestamps**

Use comments to label groups when helpful.

Example:

```sql
select
    ---------- ids
    order_id,
    customer_id,

    ---------- text
    customer_name,
    order_status,

    ---------- numerics
    amount_cents,
    {{ cents_to_dollars('amount_cents') }} as amount,

    ---------- booleans
    is_refunded,

    ---------- dates
    order_date,

    ---------- timestamps
    created_at
```

This is especially useful in import CTEs and the final output CTE.

## Naming Conventions

Consistency matters more than preference. Column names should be descriptive,
predictable, and semantically precise.

### IDs

Use:

* `<entity>_id`
* `<entity>_uuid`
* `<entity>_ulid`

Rules:

* Tables are plural; row entities are singular
* Never expose a generic `id`

Examples:

* `order_id`
* `customer_id`
* `event_uuid`

### Text

Use descriptive names with no generic suffix.

Prefer:

* `customer_name`
* `event_type`
* `payment_method`

Avoid vague names like:

* `name`
* `type`
* `status`

unless the table context makes them unambiguous everywhere downstream.

### Numerics

Include units or semantic meaning in the name.

Use:

* `<name>_<unit>`
* `<name>_rate`
* `<name>_score`
* `<name>_percentage`

Examples:

* `amount_cents`
* `amount_dollars`
* `distance_miles`
* `weight_grams`
* `conversion_rate`
* `confidence_score`
* `discount_percentage`

Never make users guess whether a field is a count, currency, ratio, or
normalized float.

### Booleans

Use a stateful prefix:

* `is_`
* `was_`
* `has_`
* `will_be_` when truly needed

Examples:

* `is_active`
* `is_refunded`
* `has_payment_method`

### Dates

Use:

* `<name>_date`

Examples:

* `signup_date`
* `cancellation_date`

Avoid:

* `signup`
* `date_of_cancellation`

### Timestamps

Use:

* `<name>_at`

Examples:

* `created_at`
* `updated_at`
* `deleted_at`

Avoid:

* `created`
* `update_time`

### Naming Test

Read the entity and column together as a sentence. If it sounds wrong, rename
it.

Good:

* `order is_refunded`
* `order was updated_at`

Bad:

* `order refund`
* `order update_time`

## Dates and Timestamps

Store dates and timestamps in UTC.

Rules:

* Keep raw storage in UTC
* Convert to local time only in downstream marts or BI layers
* Delay localization as long as possible

This reduces ambiguity and avoids repeated timezone bugs.

## Grouping and Aggregation

Prefer positional grouping when it improves maintainability:

```sql
group by 1
```

For engines that support it, use `group by all` when grouping by all
non-aggregated columns:

```sql
select
    customer_id,
    customer_name,
    count(*) as count_lifetime_orders,
    sum(amount_cents) as lifetime_spend_cents

from customers
group by all
```

Guidance:

* Use positional references intentionally, not carelessly
* Keep `select` column order stable if using positional grouping
* Use whichever style is most idiomatic and reliable for the target engine

## Joins and Aliases

### Aliases

Rules:

* Always use explicit `as`
* Never shorten aliases to single letters
* Never alias purely to save typing
* Prefer either no alias or a fully readable alias

Good:

```sql
from customers as customers
left join orders as orders
    on customers.customer_id = orders.customer_id
```

Also acceptable when needed to disambiguate role:

```sql
from employees as managers
left join employees as direct_reports
    on managers.employee_id = direct_reports.manager_id
```

Bad:

```sql
from customers as c
left join orders as o
    on c.id = o.customer_id
```

### Casing

Always use lowercase for SQL keywords, identifiers, and aliases.

## Spacing and Layout

Use whitespace to separate logical blocks, not to decorate the query.

Rules:

* If a clause spans multiple lines, indent its contents beneath the keyword
* Insert a blank line between major clauses
* Keep short clauses compact
* Make joins visually easy to scan

Example:

```sql
select
    customer_id,
    customer_name,
    count(*) as count_lifetime_orders,
    sum(amount_cents) as lifetime_spend_cents

from customers
left join orders
    on customers.customer_id = orders.customer_id

where customers.created_at >= '2024-01-01'
```

## Formatting Rules

* **indentation**: 4 spaces
* **line length**: 80 characters max
* **casing**: lowercase only
* **aliasing**: always use explicit `as`
* **commas**: trailing commas only, never leading commas
* **final select**: always `select * from <final_cte>`

Use final trailing commas only if the target engine supports them; otherwise use
standard trailing commas consistently.

## Practical Defaults

When writing SQL, default to these behaviors:

* Start with CTEs
* Separate import, transformation, and output stages
* Shrink data early
* Name each CTE after exactly one transformation
* Keep base-table access confined to import CTEs
* Group output columns by data type
* Use consistent suffixes for ids, dates, timestamps, and units
* Prefer readability over terseness
* Avoid clever aliases and compressed logic
* Make the final dataset clean enough to serve downstream consumers directly

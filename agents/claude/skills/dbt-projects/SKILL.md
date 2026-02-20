---
name: dbt-projects
description: "TODO: Complete and informative explanation of what the skill does and when to use it. Include WHEN to use this skill - specific scenarios, file types, or tasks that trigger it."
---
# dbt Project Conventions

## YAML Conventions

### Model Documentation (`*.yml`)

Each model file can contain:

- **models**: Documentation and column tests
- **data_tests**: Model-level tests
- **unit_tests**: Unit test definitions
- **semantic_models**: MetricFlow semantic layer
- **metrics**: Metric definitions
- **saved_queries**: Pre-defined metric queries

Example structure:

```yaml
models:
  - name: orders
    description: One row per order.
    data_tests:
      - dbt_utils.expression_is_true:
          expression: "order_total = subtotal + tax_paid"
    columns:
      - name: order_id
        description: Primary key.
        data_tests:
          - not_null
          - unique
```

### Source Definitions (`__sources.yml`)

Sources are defined in `models/staging/__sources.yml`:

```yaml
sources:
  - name: ecom
    schema: raw
    freshness:
      warn_after: {count: 24, period: hour}
    tables:
      - name: raw_orders
        loaded_at_field: ordered_at
```

## Macros

### `cents_to_dollars(column_name)`

Converts cents to dollars with proper decimal handling. Uses adapter dispatch for cross-database compatibility.

```sql
{{ cents_to_dollars('amount') }}  -- Returns: (amount / 100)::numeric(16, 2)
```

### `generate_schema_name(custom_schema_name, node)`

Custom schema routing:

- Seeds → `raw` schema (always)
- Prod target → `<default>_<custom>` schema naming
- Non-prod targets → default target schema

## Testing Patterns

### Data Tests

Column-level tests in YAML:

```yaml
columns:
  - name: order_id
    data_tests:
      - not_null
      - unique
      - relationships:
          to: ref('stg_orders')
          field: order_id
```

### Expression Tests

Model-level validation using `dbt_utils.expression_is_true`:

```yaml
data_tests:
  - dbt_utils.expression_is_true:
      expression: "order_total - tax_paid = subtotal"
```

### Unit Tests

Test business logic with mocked inputs:

```yaml
unit_tests:
  - name: test_order_items_compute_to_bools_correctly
    model: orders
    given:
      - input: ref('order_items')
        rows:
          - {order_id: 1, is_drink_item: true, is_food_item: false}
      - input: ref('stg_orders')
        rows:
          - {order_id: 1}
    expect:
      rows:
        - {order_id: 1, is_drink_order: true, is_food_order: false}
```

### dbt Packages Used

| Package | Version | Purpose |
| --------- | --------- | --------- |
| `dbt-labs/dbt_utils` | 1.1.1 | Common macros and tests |
| `calogica/dbt_date` | 0.10.0 | Date utilities |
| `dbt-labs/dbt-audit-helper` | main | Audit/comparison helpers |

## CI/CD

### GitHub Actions (`.github/workflows/ci.yml`)

PRs to `main` or `staging` trigger dbt Cloud CI jobs against:

- Snowflake
- BigQuery
- Postgres

Jobs create isolated schemas: `dbt_jsdx__pr_<branch_name>`

### Branching Strategy (WAP Flow)

- `main`: Production (read-only, deploys to `prod` schema)
- `staging`: Pre-production testing
- Feature branches: Branch from `staging`, merge back to `staging`

## Important Gotchas

1. **Seed paths**: The sample data lives in `jaffle-data/`. To use it, add `"jaffle-data"` to `seed-paths` in `dbt_project.yml`, run `dbt seed`, then remove it.

2. **dbt Cloud required**: This project is designed for dbt Cloud. Local dbt Core works but SQLFluff uses `dbt-cloud` templater.

3. **Raw data schema**: All source tables expect a `raw` schema in your warehouse.

4. **Schema generation**: The custom `generate_schema_name` macro routes schemas differently in prod vs non-prod environments.

5. **Packages first**: Always run `dbt deps` before `dbt build` on a fresh clone.

6. **Semantic layer**: The project includes MetricFlow semantic models and metrics, which require dbt Cloud to query interactively.

## Adding New Models

dbt Models fit into 3 broad categories: staging, intermediate, and marts.

Staging models are the rawest, closest to the source data, and should be simple transformations like renaming, type casting, and basic cleaning. They maintain a 1-to-1 relationship with a single raw source table, except in extremely rare circumstances (e.g., if the physical data from your company's orders landed in 5 identical tables split by global region, and you never interacted with those tables separately, you might choose to unify them in the staging layer into a single `stg_orders` table).

Intermediate models usually have verb names, labelled by the transformational action they apply. For instance, `int_aggregate_orders_by_customer` would be a table that joins `stg_orders` to `stg_customers` and aggregates a variety of orders facts at the customer grain. All models from the intermediate layer select from _staging models or other intermediate models **only**_, never from raw source data. The only models that should contain a `{{source()}}` macro are staging models.

Mart models are the most refined, business-facing models, they present a combination of staging and/or intermediate models to create datasets ready for analysis, BI, AI engineering, or data science work. Marts are the source of truth for the business, the user-facing end of the dbt transformation pipeline.

There are different philosophies on marts, which have upstream effects on how you design and construct your DAG. Many people build towards a star schema, which allows flexible combinations of facts and dimensions, but the other end of the spectrum, the "OBT" (One Big Table) approach is also extremely popular. OBT modeling aims to provide a convenient, pre-computed table that can service the most common query patterns in a simple and performant way, at the cost of flexibility and storage efficiency. Modern data platforms - with cheap storage separated from compute, and highly optimized query engines running on powerful, scalable machines - have changed how people weigh these options significantly.

In reality, there are many shades in-between these approaches, purists are rare, and it is not uncommon to have a mixture of both. Building a rigorous star schema of marts, then constructing a secondary layer of OBT-style marts on top of that to provide quick and easy access to key metrics is probably the most common approach in real, everyday work. Ultimately, the right approach depends on the specifics of the business and stakeholder needs.

### Staging Model Checklist

1. Create `models/staging/stg_<entity>.sql` with source → renamed CTE pattern
2. Add source table to `models/staging/__sources.yml` if new
3. Create `models/staging/stg_<entity>.yml` with description and tests
4. Follow lowercase, explicit alias, 4-space indent conventions

### Mart Model Checklist

1. Create `models/marts/<entity>.sql` joining staging models
2. Create `models/marts/<entity>.yml` with:
   - Model description
   - Column descriptions and tests
   - Semantic model definition (optional)
   - Metrics (optional)
3. Materialization defaults to `table` (configured in `dbt_project.yml`)

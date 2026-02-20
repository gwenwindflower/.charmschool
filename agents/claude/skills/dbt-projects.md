# dbt Project Conventions

## YAML Conventions

## Model Documentation (`*.yml`)

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

## Source Definitions (`__sources.yml`)

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

## `cents_to_dollars(column_name)`

Converts cents to dollars with proper decimal handling. Uses adapter dispatch for cross-database compatibility.

```sql
{{ cents_to_dollars('amount') }}  -- Returns: (amount / 100)::numeric(16, 2)
```

## `generate_schema_name(custom_schema_name, node)`

Custom schema routing:

- Seeds → `raw` schema (always)
- Prod target → `<default>_<custom>` schema naming
- Non-prod targets → default target schema

## Testing Patterns

## Data Tests

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

## Expression Tests

Model-level validation using `dbt_utils.expression_is_true`:

```yaml
data_tests:
  - dbt_utils.expression_is_true:
      expression: "order_total - tax_paid = subtotal"
```

## Unit Tests

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

## dbt Packages Used

| Package | Version | Purpose |
| --------- | --------- | --------- |
| `dbt-labs/dbt_utils` | 1.1.1 | Common macros and tests |
| `calogica/dbt_date` | 0.10.0 | Date utilities |
| `dbt-labs/dbt-audit-helper` | main | Audit/comparison helpers |

## CI/CD

## GitHub Actions (`.github/workflows/ci.yml`)

PRs to `main` or `staging` trigger dbt Cloud CI jobs against:

- Snowflake
- BigQuery
- Postgres

Jobs create isolated schemas: `dbt_jsdx__pr_<branch_name>`

## Branching Strategy (WAP Flow)

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

## Staging Model Checklist

1. Create `models/staging/stg_<entity>.sql` with source → renamed CTE pattern
2. Add source table to `models/staging/__sources.yml` if new
3. Create `models/staging/stg_<entity>.yml` with description and tests
4. Follow lowercase, explicit alias, 4-space indent conventions

## Mart Model Checklist

1. Create `models/marts/<entity>.sql` joining staging models
2. Create `models/marts/<entity>.yml` with:
   - Model description
   - Column descriptions and tests
   - Semantic model definition (optional)
   - Metrics (optional)
3. Materialization defaults to `table` (configured in `dbt_project.yml`)

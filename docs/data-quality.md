# Data Quality Strategy

This project uses two complementary quality layers:

- Soda Core for operational data quality checks on raw sources and marts
- dbt tests for model contracts and transformation consistency

## Why both Soda and dbt tests

- Soda validates freshness, volume, validity and business plausibility
- dbt enforces schema assumptions and relational integrity in transformed models
- Together they provide fast detection (Soda) and robust modeling guarantees (dbt)

## Soda checks in this project

Source checks live in `checks/sources/` and cover:

- Required IDs and duplicate protection (`orders`, `items`, `payments`, `customers`, `products`, `sellers`, `reviews`)
- Domain validity (order status, review score range, RFM segment whitelist)
- Plausibility bounds (negative values, outliers as warnings)
- Cross-table business reconciliation:
  - delivered orders should have at least one payment
  - order item totals and payment totals should stay aligned (tolerance 1 BRL, warning)

Mart checks live in `checks/marts/` and protect dashboard-ready KPIs:

- expected time-series volume
- no null business keys
- average order value in realistic range
- valid RFM segmentation

## Runbook

Run source checks:

```bash
uv run soda scan -d duckdb_raw -c soda/config.yml checks/sources/
```

Run mart checks:

```bash
# Build marts first
uv run dbt run --project-dir olist_dbt/
uv run soda scan -d duckdb_raw -c soda/config.yml checks/marts/
```

Run dbt tests:

```bash
uv run dbt test --project-dir olist_dbt/
```

## Portfolio evidence to capture

- One successful source Soda scan
- One successful mart Soda scan
- One example warning with documented decision in `checks/sources/decisions.md`
- dbt test execution screenshot or logs

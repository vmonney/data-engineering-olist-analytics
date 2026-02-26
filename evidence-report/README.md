# Evidence Dashboard

Dashboard-specific runbook for this repository.

## Prerequisites

- Node.js `>=18`
- DuckDB file available at `../data/olist.duckdb`

## Configure DuckDB source

Use `sources/needful_things/connection.yaml`:

```yaml
name: needful_things
type: duckdb
options:
  filename: ../data/olist.duckdb
```

## Required source queries

Ensure these files exist in `sources/needful_things/`:

- `mart_daily_revenue.sql`
- `mart_delivery_analysis.sql`
- `mart_customer_rfm.sql`
- `mart_product_analytics.sql`

Each file should query its corresponding mart, for example:

```sql
select * from main.mart_daily_revenue
```

## Run dashboard

From `evidence-report/`:

```bash
npm install
npm run sources
npm run dev
```

Open `http://localhost:3000`.

## Troubleshooting

- `data/manifest.json` missing: run `npm run sources` again.
- Table not found: rebuild marts from repo root with `uv run dbt run --project-dir olist_dbt/`.

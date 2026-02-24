# olist_dbt

dbt transformation project for the Olist analytics portfolio.

## Model layers

- `models/staging/`: cleaned source-aligned models (`stg_*`)
- `models/intermediate/`: business-enriched joins and reusable logic
- `models/marts/`: analytics-ready tables for BI and portfolio dashboards

## Quality approach

- Use dbt tests for model contracts (keys, relationships, accepted values)
- Use Soda checks for source/mart monitoring (volume, plausibility, cross-table controls)
- Detailed rationale: `../docs/data-quality.md`

## Runbook

From the repository root:

```bash
uv run dbt parse --project-dir olist_dbt/
uv run dbt run --project-dir olist_dbt/
uv run dbt test --project-dir olist_dbt/
```

Run only staging models:

```bash
uv run dbt run --project-dir olist_dbt/ --select staging
uv run dbt test --project-dir olist_dbt/ --select staging
```

Generate docs:

```bash
uv run dbt docs generate --project-dir olist_dbt/
uv run dbt docs serve --project-dir olist_dbt/
```

## Notes

- `stg_orders` intentionally excludes `created` and `approved` statuses.
- Some relationship tests reference `source('raw', 'raw_orders')` to stay consistent with this filtering choice.

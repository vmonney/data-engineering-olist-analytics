# olist_dbt

dbt transformation module for the Olist analytics portfolio.

## Model layers

- `models/staging/`: cleaned source-aligned models (`stg_*`)
- `models/intermediate/`: business-enriched joins and reusable logic
- `models/marts/`: analytics-ready tables for BI and portfolio dashboards

## dbt run commands

From the repository root:

```bash
uv run dbt parse --project-dir olist_dbt/
uv run dbt build --project-dir olist_dbt/
```

Run by layer:

```bash
uv run dbt run --project-dir olist_dbt/ --select staging
uv run dbt test --project-dir olist_dbt/ --select staging

uv run dbt run --project-dir olist_dbt/ --select intermediate
uv run dbt test --project-dir olist_dbt/ --select intermediate

uv run dbt run --project-dir olist_dbt/ --select marts
uv run dbt test --project-dir olist_dbt/ --select marts
```

Generate docs:

```bash
uv run dbt docs generate --project-dir olist_dbt/
uv run dbt docs serve --project-dir olist_dbt/
```

## dbt-specific caveats

- `stg_orders` intentionally excludes `created` and `approved` statuses.
- Some relationship tests reference `source('raw', 'raw_orders')` to stay consistent with that filtering choice.

## Related docs

- Project setup and full pipeline: `../docs/SETUP.md`
- Data quality design and rationale: `../docs/data-quality.md`

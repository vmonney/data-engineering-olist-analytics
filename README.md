# Olist Analytics

End-to-end analytics project built on the Brazilian Olist e-commerce dataset.
The stack demonstrates ingestion, quality gates, SQL transformation, and BI-ready marts.

## Stack

- Storage/compute: DuckDB
- Transform: dbt (`dbt-core` + `dbt-duckdb`)
- Data quality: Soda Core + dbt tests
- Python tooling: `uv`
- Linting: Ruff (Python), SQLFluff (SQL)

## Data Quality (Portfolio Highlights)

This project uses two complementary quality layers:

- **Soda Core** for source and mart checks (`checks/sources/`, `checks/marts/`)
- **dbt tests** for model-level constraints after transformations

What is covered in Soda:

- Source integrity: missing IDs, duplicates, valid domains, plausibility bounds
- Business reconciliation: delivered orders should have payments; item totals vs payment totals (warning tolerance)
- Mart protection: expected time-series volume, non-null business keys, KPI plausibility ranges

Detailed strategy and rationale: `docs/data-quality.md`

## Quality Runbook

Install dependencies (including dev tools):

```bash
uv sync --dev
```

Run Soda checks on sources:

```bash
uv run soda scan -d duckdb_raw -c soda/config.yml checks/sources/
```

Run Soda checks on marts:

```bash
# First build marts with dbt
uv run dbt run --project-dir olist_dbt/
uv run soda scan -d duckdb_raw -c soda/config.yml checks/marts/
```

Run dbt tests:

```bash
uv run dbt test --project-dir olist_dbt/
```

## Linting

Run Ruff (Python):

```bash
uv run ruff check .
uv run ruff format .
```

Auto-fix Ruff issues:

```bash
uv run ruff check . --fix
```

Run SQLFluff (SQL):

```bash
uv run sqlfluff lint . --dialect duckdb
```

Auto-fix SQLFluff issues:

```bash
uv run sqlfluff fix . --dialect duckdb
```

Run both linters via pre-commit:

```bash
uvx pre-commit run --all-files
```

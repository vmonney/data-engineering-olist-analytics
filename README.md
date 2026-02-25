# Olist Analytics

End-to-end analytics pipeline built on the Brazilian Olist e-commerce dataset (100k+ orders, 8 tables).
Demonstrates ingestion, data quality gates, SQL transformation, and a BI dashboard — fully orchestrated.

## Stack

| Tool | Role |
|------|------|
| [DuckDB](https://duckdb.org) | Embedded OLAP storage & compute |
| [dbt](https://docs.getdbt.com) + dbt-duckdb | SQL transformations (staging → intermediate → marts) |
| [Soda Core](https://docs.soda.io) | Operational data quality checks |
| [Dagster](https://dagster.io) | Pipeline orchestration, daily schedule |
| [Evidence](https://evidence.dev) | Markdown-based BI dashboard |
| [Marimo](https://marimo.io) | Interactive Python notebooks |
| uv | Python package manager |
| Ruff + SQLFluff | Python & SQL linting |

## Quick Start

```bash
uv sync                                    # install dependencies
uv run python main.py ingest               # load CSVs → DuckDB
uv run python main.py transform            # dbt build (run + test)
uv run python main.py quality              # Soda checks (sources + marts)
uv run python main.py dagster              # launch Dagster UI → http://localhost:3000
```

Full setup guide (prerequisites, dataset download, dashboard): [`docs/SETUP.md`](docs/SETUP.md)

## CLI

`main.py` provides a unified entry point:

```bash
uv run python main.py ingest      # CSV → DuckDB raw tables
uv run python main.py quality     # Soda scans on sources + marts
uv run python main.py transform   # dbt build (run + test)
uv run python main.py pipeline    # ingest + quality + transform
uv run python main.py dagster     # start Dagster UI
```

## Data Quality

Two complementary layers:

| Layer | Tool | When |
|-------|------|------|
| Source checks | Soda Core | After ingestion, before dbt |
| Model tests | dbt | During `dbt build` |
| Mart checks | Soda Core | After dbt build |

**Soda** covers: row counts, PK/FK integrity, domain validity, cross-table reconciliation.
**dbt tests** cover: uniqueness, referential integrity, accepted values, value ranges.

Documented threshold decisions: [`checks/sources/decisions.md`](checks/sources/decisions.md)
Detailed strategy: [`docs/data-quality.md`](docs/data-quality.md)

## Quality Runbook

```bash
# Soda — sources
uv run soda scan -d duckdb_raw -c soda/config.yml checks/sources/

# dbt — run + test
uv run dbt build --project-dir olist_dbt/

# Soda — marts
uv run soda scan -d duckdb_raw -c soda/config.yml checks/marts/
```

## Dashboard (Evidence)

```bash
cd evidence-report
npm install && npm run sources && npm run dev   # → http://localhost:3000
```

## Orchestration (Dagster)

Pipeline: `ingestion → source checks → dbt build → mart checks → Evidence build`

```bash
uv run python main.py dagster
# or directly:
uv run dagster dev -m pipeline.definitions
```

## Linting

```bash
uv run ruff check . --fix              # Python
uv run sqlfluff fix olist_dbt/models/  # SQL
uvx pre-commit run --all-files         # both via pre-commit
```

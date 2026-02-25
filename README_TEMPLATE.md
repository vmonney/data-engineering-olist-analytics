# [Project Name] — Data Engineering Portfolio

> One-line description: what dataset, what analytical questions, what stack.

[![CI](https://github.com/<username>/<repo>/actions/workflows/ci.yml/badge.svg)](https://github.com/<username>/<repo>/actions/workflows/ci.yml)

---

## Project Overview

| | |
|--|--|
| **Dataset** | Brief description (rows, tables, time range) |
| **Analytical goals** | 3–5 bullet points of the key business questions answered |
| **Stack** | DuckDB · dbt · Soda · Dagster · Evidence · Marimo |

---

## Architecture

```
CSV files (raw)
     │
     ▼
┌──────────────┐
│   Ingestion  │  Python script → DuckDB raw tables
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Soda (src)   │  Freshness, volume, PK/FK, domain checks
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────┐
│            dbt                   │
│  staging (views)                 │
│    → intermediate (views)        │
│      → marts (tables)            │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────┐
│ Soda (marts) │  KPI plausibility, segment coverage
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Evidence   │  Markdown-based BI dashboard
└──────────────┘

All steps orchestrated by Dagster (daily schedule)
Interactive exploration via Marimo notebooks
```

---

## Tech Stack

| Tool | Role | Version |
|------|------|---------|
| [DuckDB](https://duckdb.org) | Embedded OLAP storage & compute | ≥ 1.4 |
| [dbt-core](https://docs.getdbt.com) | SQL transformations & tests | 1.8.x |
| [dbt-duckdb](https://github.com/duckdb/dbt-duckdb) | dbt adapter for DuckDB | 1.8.x |
| [Soda Core](https://docs.soda.io) | Operational data quality checks | 3.3.x |
| [Dagster](https://dagster.io) | Pipeline orchestration & scheduling | ≥ 1.12 |
| [Evidence](https://evidence.dev) | Markdown-based BI dashboard | ≥ 40 |
| [Marimo](https://marimo.io) | Reactive Python notebooks | ≥ 0.20 |
| [uv](https://docs.astral.sh/uv) | Fast Python package manager | latest |
| [Ruff](https://docs.astral.sh/ruff) | Python linter & formatter | ≥ 0.15 |
| [SQLFluff](https://sqlfluff.com) | SQL linter (DuckDB dialect) | ≥ 4.0 |

---

## Prerequisites

- Python 3.11
- Node.js ≥ 18
- uv (`curl -LsSf https://astral.sh/uv/install.sh | sh`)

---

## Quick Start

```bash
# 1. Clone & install
git clone https://github.com/<username>/<repo>.git && cd <repo>
uv sync && uv run pre-commit install

# 2. Place raw CSV files in data/raw/csv/  (see docs/SETUP.md)

# 3. Ingest into DuckDB
uv run python main.py ingest

# 4. Transform with dbt
uv run python main.py transform

# 5. Launch dashboard
cd evidence-report && npm install && npm run sources && npm run dev
```

Full setup guide: [`docs/SETUP.md`](docs/SETUP.md)

---

## Project Structure

```
.
├── data/
│   ├── raw/csv/               # Source CSV files (not tracked in git)
│   └── <project>.duckdb       # DuckDB database (not tracked)
│
├── scripts/
│   └── ingest_csv_to_parquet.py   # CSV → DuckDB raw tables
│
├── <project>_dbt/             # dbt project
│   └── models/
│       ├── staging/           # One view per source table, cleaned
│       ├── intermediate/      # Business logic, joins, enrichments
│       └── marts/             # Analytics-ready tables (materialized)
│
├── checks/
│   ├── sources/               # Soda checks on raw tables
│   │   └── decisions.md       # Documented threshold decisions
│   └── marts/                 # Soda checks on mart tables
│
├── soda/config.yml            # Soda datasource config
│
├── pipeline/
│   └── definitions.py         # Dagster assets & daily schedule
│
├── evidence-report/           # Evidence BI dashboard
│   ├── pages/index.md         # Dashboard page (SQL + charts)
│   └── sources/<project>/     # SQL queries & DuckDB connection
│
├── notebooks/
│   └── 01_exploration.py      # Marimo interactive exploration
│
├── docs/
│   ├── data-quality.md        # Quality strategy & rationale
│   └── SETUP.md               # Step-by-step setup guide
│
├── main.py                    # CLI entry point
└── pyproject.toml             # Dependencies (uv)
```

---

## Data Quality Strategy

Two complementary layers:

| Layer | Tool | When | What |
|-------|------|------|------|
| **Source checks** | Soda | After ingestion, before dbt | Volume, PK/FK integrity, domain validity, cross-table reconciliation |
| **Model tests** | dbt | During `dbt build` | Uniqueness, referential integrity, accepted values, value ranges |
| **Mart checks** | Soda | After dbt build | KPI plausibility, segment coverage, business rules |

**Rule of thumb:**
- Use **Soda** for operational monitoring (is the data fresh? are row counts right?)
- Use **dbt tests** for modeling correctness (are keys unique? are foreign keys valid?)

Documented threshold decisions: [`checks/sources/decisions.md`](checks/sources/decisions.md)

---

## Running the Pipeline

**Full pipeline (CLI):**
```bash
uv run python main.py pipeline      # ingest + quality + transform
uv run python main.py ingest        # CSV → DuckDB only
uv run python main.py transform     # dbt build only
uv run python main.py quality       # Soda scans only
```

**Dagster UI:**
```bash
uv run python main.py dagster       # http://localhost:3000
```

**Manual dbt commands:**
```bash
uv run dbt seed --project-dir <project>_dbt/
uv run dbt run --project-dir <project>_dbt/
uv run dbt test --project-dir <project>_dbt/
uv run dbt build --project-dir <project>_dbt/      # run + test combined
uv run dbt docs generate --project-dir <project>_dbt/ && uv run dbt docs serve --project-dir <project>_dbt/
```

---

## Dashboard

Evidence dashboard powered by DuckDB:

```bash
cd evidence-report
npm install          # first time only
npm run sources      # regenerate data manifest after dbt build
npm run dev          # http://localhost:3000
npm run build        # production build → build/
```

---

## Development

**Linting:**
```bash
uv run ruff check .                                # Python lint
uv run ruff format .                               # Python format
uv run sqlfluff lint <project>_dbt/models/         # SQL lint
uv run sqlfluff fix <project>_dbt/models/          # SQL auto-fix
```

**Pre-commit (runs automatically on `git commit`):**
```bash
uv run pre-commit install   # one-time setup
uv run pre-commit run --all-files
```

---

## Testing

```bash
# dbt model tests
uv run dbt test --project-dir <project>_dbt/

# Soda source checks
uv run soda scan -d duckdb_raw -c soda/config.yml checks/sources/

# Soda mart checks
uv run soda scan -d duckdb_raw -c soda/config.yml checks/marts/
```

---

## Contributing

**Branch naming:** `feat/<topic>`, `fix/<topic>`, `docs/<topic>`

**SQL conventions:**
- Model names: `<layer>_<entity>.sql` (e.g. `stg_orders.sql`, `mart_customer_rfm.sql`)
- CTEs over subqueries; final `SELECT` always last
- All models have a YAML contract (`_staging.yml`, `_intermediate.yml`, `_marts.yml`)

**Python conventions:** Ruff-enforced, type hints on public functions.

**Commit format:** `<type>: <short description>` (feat / fix / docs / refactor / test / chore)

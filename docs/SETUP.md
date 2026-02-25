# Getting Started

Set up the full Olist Analytics pipeline in 5 steps.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Python | 3.11 | [python.org](https://python.org) |
| uv | latest | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Node.js | ≥ 18 | [nodejs.org](https://nodejs.org) |
| Kaggle CLI (optional) | latest | `pip install kaggle` |

---

## Step 1 — Clone & install dependencies

```bash
git clone https://github.com/<your-username>/olist-analytics.git
cd olist-analytics

# Install Python dependencies (creates .venv automatically)
uv sync

# Install pre-commit hooks
uv run pre-commit install
```

## Step 2 — Download the Olist dataset

Download the [Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle and place all CSV files in `data/raw/csv/`:

```
data/raw/csv/
├── olist_customers_dataset.csv
├── olist_geolocation_dataset.csv
├── olist_order_items_dataset.csv
├── olist_order_payments_dataset.csv
├── olist_order_reviews_dataset.csv
├── olist_orders_dataset.csv
├── olist_products_dataset.csv
└── olist_sellers_dataset.csv
```

**With Kaggle CLI:**
```bash
kaggle datasets download -d olistbr/brazilian-ecommerce --unzip -p data/raw/csv
```

## Step 3 — Ingest data into DuckDB

```bash
uv run python main.py ingest
# or directly: uv run python scripts/ingest_csv_to_parquet.py
```

This creates `data/olist.duckdb` with all 8 raw tables.

## Step 4 — Run the transformation pipeline

```bash
# Run dbt build (run + test) in one command
uv run python main.py transform
# or: uv run dbt build --project-dir olist_dbt/
```

This materialises all staging views, intermediate views, and mart tables.

## Step 5 — Launch the dashboard

```bash
cd evidence-report
npm install
npm run sources   # generate data manifest
npm run dev       # open http://localhost:3000
```

---

## Full pipeline (all steps at once)

```bash
uv run python main.py pipeline
```

## Dagster UI (orchestration)

```bash
uv run python main.py dagster
# then open http://localhost:3000
```

## Data quality checks only

```bash
uv run python main.py quality
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `dbt build` fails: profile not found | Check `~/.dbt/profiles.yml` — see `olist_dbt/README.md` for the expected profile |
| Soda `FAIL`: row count out of range | Re-run ingestion — the CSV may be incomplete |
| Evidence `manifest.json` not found | Run `npm run sources` before `npm run dev` |
| DuckDB lock error | Close any other process using `data/olist.duckdb` |
